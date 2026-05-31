package engine

import (
	"context"
	"fmt"
	"log"
	"strings"
	"sync"

	ctxpkg "github.com/eastbadman/agent-study/go-tiny-claw/internal/context"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/provider"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/schema"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/tools"
)

const maxTurns = 15

// AgentEngine 是微型 OS 的核心驱动
type AgentEngine struct {
	provider       provider.LLMProvider
	registry       tools.Registry
	EnableThinking bool
}

// 【注意】：我们移除了 Engine 层级的 WorkDir，因为 WorkDir 现在应该跟随 Session 走！
func NewAgentEngine(p provider.LLMProvider, r tools.Registry, enableThinking bool) *AgentEngine {
	return &AgentEngine{
		provider:       p,
		registry:       r,
		EnableThinking: enableThinking,
	}
}

func (e *AgentEngine) Run(ctx context.Context, session *ctxpkg.Session, reporter Reporter) error {
	log.Printf("[Engine] 唤醒会话 [%s]，锁定工作区: %s\n", session.ID, session.WorkDir)

	// 根据当前 Session 的工作区，动态组装最新的 System Prompt
	composer := ctxpkg.NewPromptComposer(session.WorkDir)
	systemMsg := composer.Build()

	log.Printf("[Engine] 慢思考模式 (Thinking Phase): %v\n", e.EnableThinking)

	turnCount := 0

	for {
		turnCount++
		log.Printf("\n========== [Turn %d] 开始 ==========\n", turnCount)

		if turnCount > maxTurns {
			log.Printf("[Engine] 已达到最大轮次上限 (%d)，强制终止。\n", maxTurns)
			break
		}

		availableTools := e.registry.GetAvailableTools()

		// 1. 【上下文组装】: System Prompt + 截取最近的 6 条消息作为 Working Memory
		// 在实际业务中，由于工具返回结果可能很长，短期工作记忆往往设为 6-10 条足以维系连贯对话
		workingMemory := session.GetWorkingMemory(6)

		var contextHistory []schema.Message
		contextHistory = append(contextHistory, systemMsg)
		contextHistory = append(contextHistory, workingMemory...)

		// ====================================================================
		// Phase 1: 慢思考阶段 (Thinking) - 剥夺工具，强制规划
		// ====================================================================
		if e.EnableThinking {
			log.Println("[Engine][Phase 1] 剥夺工具访问权，强制进入慢思考与规划阶段...")

			if reporter != nil {
				reporter.OnThinking(ctx)
			}

			thinkResp, err := e.provider.Generate(ctx, contextHistory, nil)
			if err != nil {
				return fmt.Errorf("Thinking 阶段生成失败: %w", err)
			}

			if thinkResp.Content != "" {
				fmt.Printf("🧠 [内部思考 Trace]: %s\n", thinkResp.Content)
				contextHistory = append(contextHistory, *thinkResp)
			}

			// 检测 [TASK_COMPLETE] 信号：模型确认任务完成时主动发出
			if strings.Contains(thinkResp.Content, "[TASK_COMPLETE]") {
				cleanContent := strings.Replace(thinkResp.Content, "[TASK_COMPLETE]", "", -1)
				cleanContent = strings.TrimSpace(cleanContent)
				if cleanContent != "" {
					fmt.Printf("🤖 [对外回复]: %s\n", cleanContent)
					if reporter != nil {
						reporter.OnMessage(ctx, cleanContent)
					}
				}
				log.Println("[Engine] Phase 1 检测到任务完成信号，任务完成。")
				break
			}
		}

		// ====================================================================
		// Phase 2: 行动阶段 (Action) - 恢复工具，顺着规划执行
		// ====================================================================
		log.Println("[Engine][Phase 2] 恢复工具挂载，等待模型采取行动...")

		actionResp, err := e.provider.Generate(ctx, contextHistory, availableTools)
		if err != nil {
			return fmt.Errorf("Action 阶段生成失败: %w", err)
		}

		session.Append(*actionResp)
		contextHistory = append(contextHistory, *actionResp)

		if actionResp.Content != "" {
			if reporter != nil {
				reporter.OnMessage(ctx, actionResp.Content)
			}
		}

		// ====================================================================
		// 退出与执行逻辑
		// ====================================================================
		if len(actionResp.ToolCalls) == 0 {
			log.Println("[Engine] 模型未请求调用工具，任务宣告完成。")
			break
		}

		log.Printf("[Engine] 模型请求并发调用 %d 个工具...\n", len(actionResp.ToolCalls))

		observationMsgs := make([]schema.Message, len(actionResp.ToolCalls))
		var wg sync.WaitGroup

		for i, toolCall := range actionResp.ToolCalls {
			wg.Add(1)

			go func(idx int, call schema.ToolCall) {
				defer wg.Done()

				log.Printf("  -> [Go-%d] 🛠️ 触发并行执行: %s\n", idx, call.Name)

				if reporter != nil {
					reporter.OnToolCall(ctx, call.Name, string(call.Arguments))
				}

				result := e.registry.Execute(ctx, call)

				if reporter != nil {
					displayOutput := result.Output
					if len(displayOutput) > 200 {
						displayOutput = displayOutput[:200] + "... (已截断)"
					}
					reporter.OnToolResult(ctx, call.Name, displayOutput, result.IsError)
				}

				if result.IsError {
					log.Printf("  -> [Go-%d] ❌ 工具执行报错: %s\n", idx, result.Output)
				} else {
					log.Printf("  -> [Go-%d] ✅ 工具执行成功 (返回 %d 字节)\n", idx, len(result.Output))
				}

				observationMsgs[idx] = schema.Message{
					Role:       schema.RoleUser,
					Content:    result.Output,
					ToolCallID: call.ID,
				}
			}(i, toolCall)
		}

		wg.Wait()
		log.Println("[Engine] 所有并发工具执行完毕，开始聚合观察结果 (Observation)...")

		session.Append(observationMsgs...)
	}

	return nil
}
