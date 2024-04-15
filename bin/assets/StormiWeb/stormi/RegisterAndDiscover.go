package stormi

import (
	"errors"
	"fmt"
	"log"
	"math/rand"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/go-redis/redis"
	"gopkg.in/yaml.v2"
)

type Config struct {
	Stormi struct {
		Redis struct {
			Url      string `yaml:"url"`
			Password string `yaml:"password"`
		} `yaml:"redis"`

		Server struct {
			Name   string `yaml:"name"`
			Port   string `yaml:"port"`
			Weight int    `yaml:"weight"`
		} `yaml:"server"`
	} `yaml:"stormi"`
}

func GetPort() string {
	// 获取当前工作目录
	wd, _ := os.Getwd()

	// 寻找包含 go.mod 文件的目录
	modDir := findModDir(wd)
	yamlFile, err := os.ReadFile(modDir + "/app.yaml")
	if err != nil {
		log.Fatalf("failed to read YAML file: %v", err)
	}

	yaml.Unmarshal(yamlFile, &config)
	return config.Stormi.Server.Port
}

var rds *redis.Client
var config Config

func GetRedisClient() *redis.Client {
	return rds
}

func init() {

	// 获取当前工作目录
	wd, _ := os.Getwd()

	// 寻找包含 go.mod 文件的目录
	modDir := findModDir(wd)
	yamlFile, err := os.ReadFile(modDir + "/app.yaml")

	// 获取当前进程的 PID
	pid := os.Getpid()

	// 将 PID 转换为字符串
	pidStr := strconv.Itoa(pid)

	// 写入 PID 到文件中
	os.WriteFile(modDir+"/processid", []byte(pidStr), 0644)

	if err != nil {
		log.Fatalf("failed to read YAML file: %v", err)
	}

	err = yaml.Unmarshal(yamlFile, &config)
	if err != nil {
		log.Fatalf("failed to unmarshal YAML: %v", err)
	}

	//fmt.Println(config.Info.Url, config.Info.Password)

	if config.Stormi.Redis.Url == "" {
		log.Fatalf("请设置redis信息")
	}

	config.Stormi.Server.Port = strconv.Itoa(findAvailablePort())

	rds = redis.NewClient(&redis.Options{
		Addr:     config.Stormi.Redis.Url,
		Password: config.Stormi.Redis.Password,
		DB:       0,
	})
}

// findModDir 寻找包含 go.mod 文件的目录
func findModDir(dir string) string {
	for {
		// 检查当前目录是否包含 go.mod 文件
		if _, err := os.Stat(filepath.Join(dir, "go.mod")); err == nil {
			return dir
		}

		// 如果已经到达根目录，则停止搜索
		parentDir := filepath.Dir(dir)
		if parentDir == dir {
			break
		}

		// 继续向上一级目录搜索
		dir = parentDir
	}

	return ""
}

func findAvailablePort() int {
	// 创建一个新的随机数生成器
	randSource := rand.NewSource(time.Now().UnixNano())
	random := rand.New(randSource)

	// 定义扫描的起始端口和结束端口
	startPort := 1
	endPort := 65535

	// 循环检查每个端口的连接状态
	for {
		// 随机选择一个端口进行检查
		randomPort := startPort + random.Intn(endPort-startPort+1)

		// 跳过8000到10000之间的端口
		if randomPort >= 8000 && randomPort < 10000 {
			continue
		}

		addr := fmt.Sprintf(":%d", randomPort)

		// 尝试在随机选择的端口建立 TCP 连接
		listener, err := net.Listen("tcp", addr)
		if err == nil {
			// 如果没有错误，则说明端口可用
			defer listener.Close()
			return randomPort
		}

		// 如果端口不可用，则尝试下一个端口
		fmt.Printf("端口 %d 不可用，尝试其他端口\n", randomPort)
	}
}

func RegisterWithName(serverName string) {
	config.Stormi.Server.Name = serverName
	go func() {
		Register()
	}()
	time.Sleep(50 * time.Millisecond)
}

func Register() {
	serverName := config.Stormi.Server.Name
	port := config.Stormi.Server.Port
	weight := config.Stormi.Server.Weight
	if serverName == "" {
		log.Fatalf("未设置服务名")
	}

	config.Stormi.Server.Port = port

	if weight == 0 {
		weight = 1
	}
	addr := getNetworkAddress() + ":" + port
	var prefix = "stormi:"
	serverName = prefix + serverName
	count := 0
	for i := 1; i <= weight; i++ {
		rds.SAdd(serverName, addr+"-"+strconv.Itoa(weight)+"-"+strconv.Itoa(i))
	}
	rds.Expire(serverName, 60*time.Second)
	for i := 1; i <= weight; i++ {
		rds.Set(serverName+addr, weight, 5*time.Second)
	}
	go func() {
		for {
			if count%10 == 0 {
				for i := 1; i <= weight; i++ {
					rds.SAdd(serverName, addr+"-"+strconv.Itoa(weight)+"-"+strconv.Itoa(i))
				}
				rds.Expire(serverName, 60*time.Second)
			}
			for i := 1; i <= weight; i++ {
				rds.Set(serverName+addr, weight, 5*time.Second)
			}
			time.Sleep(3 * time.Second)
			count++
		}
	}()
}

func discovery(cloudServerName string) (string, error) {
	var prefix = "stormi:"
	serverName := prefix + cloudServerName
	var err error

	res, _ := rds.SRandMember(serverName).Result()
	if res == "" {
		for i := 1; i <= 10; i++ {
			time.Sleep(100 * time.Millisecond)
			res, _ = rds.SRandMember(serverName).Result()
			if res != "" {
				break
			}
		}

		return "", errors.New("未发现服务")
	}
	parts := strings.Split(res, "-")
	addr := parts[0]
	weight, _ := strconv.Atoi(parts[1])

	result, _ := rds.Get(serverName + addr).Result()
	if w, _ := strconv.Atoi(result); w != weight {
		for i := 1; i <= weight; i++ {
			rds.SRem(serverName, addr+"-"+strconv.Itoa(weight)+"-"+strconv.Itoa(i))
		}
		addr, err = discovery(cloudServerName)
	}

	return addr, err
}

func getNetworkAddress() string {
	// 获取本地网络接口信息
	interfaces, err := net.Interfaces()
	if err != nil {
		fmt.Println(err)
	}

	// 遍历每个网络接口
	for _, iface := range interfaces {
		// 排除回环接口和虚拟接口
		if iface.Flags&net.FlagLoopback != 0 || iface.Flags&net.FlagUp == 0 {
			continue
		}

		// 获取网络接口的地址列表
		addrs, err := iface.Addrs()
		if err != nil {
			fmt.Println(err)
		}

		// 遍历每个地址
		for _, addr := range addrs {
			switch v := addr.(type) {
			case *net.IPNet:
				// 检查是否是 IPv4 地址
				if v.IP.To4() != nil {
					if v.IP.IsGlobalUnicast() {
						// 共有网络地址
						return v.IP.String()
					} else if isPrivateIP(v.IP) {
						// 私有网络地址
						return v.IP.String()
					}
				}
			}
		}
	}
	fmt.Println("No network address found")
	return ""
}

// 检查IP地址是否是私有地址
func isPrivateIP(ip net.IP) bool {
	// 私有地址范围：10.0.0.0/8、172.16.0.0/12、192.168.0.0/16
	privateRanges := []*net.IPNet{
		{IP: net.IPv4(10, 0, 0, 0), Mask: net.CIDRMask(8, 32)},
		{IP: net.IPv4(172, 16, 0, 0), Mask: net.CIDRMask(12, 32)},
		{IP: net.IPv4(192, 168, 0, 0), Mask: net.CIDRMask(16, 32)},
	}

	// 检查IP地址是否属于私有地址范围
	for _, pr := range privateRanges {
		if pr.Contains(ip) {
			return true
		}
	}

	return false
}
