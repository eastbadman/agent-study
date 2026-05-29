package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

// jsonResponse 统一返回 JSON 格式的响应，包含 code、message、data 字段
func jsonResponse(w http.ResponseWriter, code int, message string, data interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(code)
	resp := map[string]interface{}{
		"code":    code,
		"message": message,
		"data":    data,
	}
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		log.Printf("JSON 编码失败: %v", err)
	}
}

// pingHandler 处理 /ping 请求，返回服务健康检查结果
func pingHandler(w http.ResponseWriter, r *http.Request) {
	jsonResponse(w, http.StatusOK, "pong", nil)
}

func main() {
	http.HandleFunc("/ping", pingHandler)

	port := ":18080"
	fmt.Printf("Ping 服务已启动，监听端口 %s\n", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("服务启动失败: %v", err)
	}
}
