package main

import (
    "context"
    "log"
    "os"

    "github.com/eastbadman/agent-study/go-tiny-claw/internal/engine"
    "github.com/eastbadman/agent-study/go-tiny-claw/internal/schema"
    "github.com/eastbadman/agent-study/go-tiny-claw/internal/provider"

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
	var llmProvider provider.LLMProvider

	workDir, _ := os.Getwd()

	// 根据环境变量选择 Provider，默认使用 DeepSeek
	providerName := os.Getenv("LLM_PROVIDER")
	switch providerName {
	case "zhipu":
		llmProvider = provider.NewZhipuOpenAIProvider("glm-4.5-air")
	case "claude":
		llmProvider = provider.NewZhipuClaudeProvider("claude-3-5-sonnet-20241022")
	default:
		llmProvider = provider.NewDeepSeekProvider("deepseek-v4-pro")
	}
	registry := &mockRegistry{}

	eng := engine.NewAgentEngine(llmProvider, registry, workDir, true)

	prompt := "我想去北京跑步，帮我查查天气适合吗？"

	err := eng.Run(context.Background(), prompt)
	if err != nil {
		log.Fatalf("引擎运行崩溃: %v", err)
	}
}