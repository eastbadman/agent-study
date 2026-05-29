package main

import (
	"encoding/json"
	"net/http"
)

// pingHandler 处理 /ping 请求，返回服务健康检查结果
func pingHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	resp := map[string]interface{}{
		"code":    http.StatusOK,
		"message": "pong",
		"data":    nil,
	}
	json.NewEncoder(w).Encode(resp)
}
