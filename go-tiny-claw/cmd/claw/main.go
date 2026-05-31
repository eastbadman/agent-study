package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/eastbadman/agent-study/go-tiny-claw/internal/config"
	ctxpkg "github.com/eastbadman/agent-study/go-tiny-claw/internal/context"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/engine"

	/* "github.com/eastbadman/agent-study/go-tiny-claw/internal/feishu" */
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
	projectDir, _ := os.Getwd()
	workDir := filepath.Join(projectDir, "workspace")
	configPath := filepath.Join(projectDir, "config.json")

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

	registry := tools.NewRegistry()
	registry.Register(tools.NewReadFileTool(workDir))
	registry.Register(tools.NewWriteFileTool(workDir))
	registry.Register(tools.NewBashTool(workDir))

	// 实例化引擎 (关闭思考模式以提速)
	eng := engine.NewAgentEngine(llmProvider, registry, false)
	reporter := engine.NewTerminalReporter()

	sessionID := "test_oom_protection_001"
	sess := ctxpkg.GlobalSessionMgr.GetOrCreate(sessionID, workDir)

	// 发起一个会导致读取大文件的恶意任务
	prompt := `
    请帮我执行以下三个步骤：
    1. 使用 bash 执行 echo "开始排查日志"
    2. 使用 read_file 工具读取当前目录下的巨大文件 generate_default_rose_data_rule.sh
    3. 使用 bash 执行 date 命令获取当前时间，并告诉我任务全部完成。
    `

	sess.Append(schema.Message{Role: schema.RoleUser, Content: prompt})

	err = eng.Run(context.Background(), sess, reporter)
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
