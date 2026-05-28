package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/eastbadman/agent-study/go-tiny-claw/internal/config"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/engine"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/provider"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/schema"
)

type mockRegistry struct{}

func (m *mockRegistry) GetAvailableTools() []schema.ToolDefinition {
	return []schema.ToolDefinition{
		{
			Name:        "get_weather",
			Description: "获取指定城市的当前天气情况。",
			InputSchema: map[string]interface{}{
				"type": "object",
				"properties": map[string]interface{}{
					"city": map[string]interface{}{
						"type": "string",
					},
				},
				"required": []string{"city"},
			},
		},
	}
}

func (m *mockRegistry) Execute(ctx context.Context, call schema.ToolCall) schema.ToolResult {
	log.Printf("  -> [Mock 工具执行] 获取 %s 的天气中...\n", call.Name)
	return schema.ToolResult{
		ToolCallID: call.ID,
		Output:     "API 返回：今天是晴天，气温 25 度。天气很好",
		IsError:    false,
	}
}

func main() {
	workDir, _ := os.Getwd()
	configPath := filepath.Join(workDir, "config.json")

	cfg, err := config.Load(configPath)
	if err != nil {
		log.Fatalf("加载配置文件失败: %v", err)
	}

	var llmProvider provider.LLMProvider

	switch cfg.Provider {
	case "zhipu":
		llmProvider = provider.NewZhipuOpenAIProvider(cfg.Zhipu.APIKey, cfg.Zhipu.Model, cfg.Zhipu.BaseURL)
	case "claude":
		llmProvider = provider.NewZhipuClaudeProvider(cfg.Zhipu.APIKey, cfg.Zhipu.Model, cfg.Zhipu.BaseURL)
	case "deepseek":
		llmProvider = provider.NewDeepSeekProvider(cfg.DeepSeek.APIKey, cfg.DeepSeek.Model, cfg.DeepSeek.BaseURL)
	default:
		log.Fatalf("未知的 provider: %s，请选择 deepseek/zhipu/claude", cfg.Provider)
	}

	fmt.Printf("当前 Provider: %s, Model: %s\n", cfg.Provider, modelOf(cfg))

	registry := &mockRegistry{}

	eng := engine.NewAgentEngine(llmProvider, registry, workDir, true)

	prompt := "我想去北京跑步，帮我查查天气适合吗？"

	err = eng.Run(context.Background(), prompt)
	if err != nil {
		log.Fatalf("引擎运行崩溃: %v", err)
	}
}

func modelOf(cfg *config.Config) string {
	switch cfg.Provider {
	case "deepseek":
		return cfg.DeepSeek.Model
	case "zhipu", "claude":
		return cfg.Zhipu.Model
	default:
		return "unknown"
	}
}
