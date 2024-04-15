package stormi

import (
	"fmt"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func GetCloudConn(serverName string) *grpc.ClientConn {
	addr, _ := discovery(serverName)

	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		fmt.Println(err)
	}

	return conn
}

func GetConn(serverName string) *grpc.ClientConn {
	addr := serverName

	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		fmt.Println("连接失败")
	}

	return conn
}
