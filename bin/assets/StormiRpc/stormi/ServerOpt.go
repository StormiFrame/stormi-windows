package stormi

import (
	"fmt"
	"net"

	"google.golang.org/grpc"
)

var rpc *grpc.Server

func init() {
	rpc = grpc.NewServer()
}
func GetStormiRpc() *grpc.Server {
	return rpc
}

func StartServer() {
	listen, err := net.Listen("tcp", ":"+config.Stormi.Server.Port)
	if err != nil {
		fmt.Println(err.Error())
	}

	fmt.Println(config.Stormi.Server.Name, "服务启动,监听端口:", config.Stormi.Server.Port)

	err = rpc.Serve(listen)
	if err != nil {
		fmt.Println(err.Error())
	}

}
