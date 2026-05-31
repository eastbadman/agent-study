package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sync"
	"time"

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
	//workDir := filepath.Join(projectDir, "workspace")
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
	registry.Register(tools.NewReadFileTool("D:\\code\\agent\\project_front"))

	// 引擎本身变成无状态的，它不绑定 WorkDir（仅适用于本讲演示）
	eng := engine.NewAgentEngine(llmProvider, registry, false)
	reporter := engine.NewTerminalReporter()

	var wg sync.WaitGroup

	// ================= 模拟并发场景 1：飞书前端群 =================
	wg.Add(1)
	go func() {
		defer wg.Done()
		sessionA := ctxpkg.GlobalSessionMgr.GetOrCreate("chat_front_001", "D:\\code\\agent\\project_front")

		// 回合 1：获取机密
		log.Println("\n>>> 🙋‍♂️ [Session A / Turn 1]: 帮我看看 README.md 里记录了什么密钥？")
		sessionA.Append(schema.Message{Role: schema.RoleUser, Content: "帮我看看 README.md 里记录了什么密钥？"})
		_ = eng.Run(context.Background(), sessionA, reporter)

		// 故意制造大量“废话”对话，刷掉记忆 (假设 Working Memory Limit=6)
		for i := 0; i < 6; i++ {
			sessionA.Append(schema.Message{Role: schema.RoleUser, Content: "这只是一句闲聊占位符。"})
			sessionA.Append(schema.Message{Role: schema.RoleAssistant, Content: "好的，收到闲聊。"})
		}

		// 回合 2：验证记忆截断 (此时第一轮的密钥已经被挤出 Working Memory 了！)
		log.Println("\n>>> 🙋‍♂️ [Session A / Turn 2]: 请直接告诉我，刚才第一轮你查到的那个密钥是什么？")
		sessionA.Append(schema.Message{Role: schema.RoleUser, Content: "请直接告诉我，刚才第一轮你查到的那个密钥是什么？不准调用工具！"})
		_ = eng.Run(context.Background(), sessionA, reporter)
	}()

	// ================= 模拟并发场景 2：飞书后端群 =================
	wg.Add(1)
	go func() {
		defer wg.Done()
		// 稍微错开一点时间发起请求
		time.Sleep(1 * time.Second)

		sessionB := ctxpkg.GlobalSessionMgr.GetOrCreate("chat_back_002", "/tmp/project_back")

		log.Println("\n>>> 🙋‍♂️ [Session B]: 别人查到了一个密钥，你这里能看到吗？")
		sessionB.Append(schema.Message{Role: schema.RoleUser, Content: "别人查到了一个密钥，你这里能看到吗？不准调用工具！"})
		_ = eng.Run(context.Background(), sessionB, reporter)
	}()

	wg.Wait()
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
