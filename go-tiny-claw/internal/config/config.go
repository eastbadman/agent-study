package config

import (
	"encoding/json"
	"fmt"
	"os"
)

type Config struct {
	Provider string       `json:"provider"`
	DeepSeek DeepSeekConf `json:"deepseek"`
	Zhipu    ZhipuConf    `json:"zhipu"`
}

type DeepSeekConf struct {
	APIKey  string `json:"api_key"`
	Model   string `json:"model"`
	BaseURL string `json:"base_url"`
}

type ZhipuConf struct {
	APIKey  string `json:"api_key"`
	Model   string `json:"model"`
	BaseURL string `json:"base_url"`
}

func Load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("读取配置文件 %s 失败: %w", path, err)
	}

	var cfg Config
	if err := json.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("解析配置文件 %s 失败: %w", path, err)
	}

	return &cfg, nil
}
