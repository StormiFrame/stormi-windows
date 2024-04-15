package stormi

import (
	"github.com/gin-gonic/gin"
)

var r *gin.Engine

func init() {
	r = gin.Default()
}

func GetEngine() *gin.Engine {
	return r
}
