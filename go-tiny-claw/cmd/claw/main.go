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
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/tools"
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

	// 3. 初始化真实的 Tool Registry
	registry := tools.NewRegistry()
	// 4. 将真实的 ReadFile 工具挂载到注册表中
	registry.Register(tools.NewReadFileTool(workDir))
	registry.Register(tools.NewWriteFileTool(workDir))
	registry.Register(tools.NewBashTool(workDir))
	registry.Register(tools.NewEditFileTool(workDir))
	// 5. 实例化核心引擎，由于任务简单，我们关闭思考阶段 (EnableThinking = false) 以加快速度
	eng := engine.NewAgentEngine(llmProvider, registry, workDir, true)

	prompt := `
	我当前目录下有 a.txt, b.txt, c.txt 三个文件。
    为了节省时间，请你同时一次性读取这三个文件，使用read_file工具，并将它们的内容综合起来，告诉我它们分别记录了什么领域的信息。
	`

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
