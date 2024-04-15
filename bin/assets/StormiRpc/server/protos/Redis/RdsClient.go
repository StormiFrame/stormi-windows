package redis

import (
	"Stormi/stormi"

	"github.com/go-redis/redis"
)

var RdsClient *redis.Client

func init() {
	RdsClient = stormi.GetRedisClient()
}
