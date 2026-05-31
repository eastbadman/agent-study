// internal/feishu/bot.go
package feishu

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/eastbadman/agent-study/go-tiny-claw/internal/config"
	ctxpkg "github.com/eastbadman/agent-study/go-tiny-claw/internal/context"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/engine"
	"github.com/eastbadman/agent-study/go-tiny-claw/internal/schema"
	larkcore "github.com/larksuite/oapi-sdk-go/v3/core"
	"github.com/larksuite/oapi-sdk-go/v3/event/dispatcher"
	larkim "github.com/larksuite/oapi-sdk-go/v3/service/im/v1"
	larkws "github.com/larksuite/oapi-sdk-go/v3/ws"

	lark "github.com/larksuite/oapi-sdk-go/v3"
)

// FeishuBot 封装了飞书机器人的配置与核心业务流
type FeishuBot struct {
	client    *lark.Client
	appID     string
	appSecret string
	engine    *engine.AgentEngine // 持有核心引擎引用
}

func NewFeishuBot(eng *engine.AgentEngine, cfg *config.FeishuConf) *FeishuBot {
	if cfg.AppID == "" || cfg.AppSecret == "" {
		log.Fatal("请配置 feishu.app_id 和 feishu.app_secret")
	}

	client := lark.NewClient(cfg.AppID, cfg.AppSecret)

	return &FeishuBot{
		client:    client,
		appID:     cfg.AppID,
		appSecret: cfg.AppSecret,
		engine:    eng,
	}
}

// GetEventDispatcher 构建事件调度器（WebSocket 长连接模式下不需要验证 token 和加密 key）
func (b *FeishuBot) GetEventDispatcher() *dispatcher.EventDispatcher {
	handler := dispatcher.NewEventDispatcher("", "").
		OnP2MessageReceiveV1(func(ctx context.Context, event *larkim.P2MessageReceiveV1) error {
			contentStr := *event.Event.Message.Content
			contentStr = strings.TrimPrefix(contentStr, `{"text":"`)
			contentStr = strings.TrimSuffix(contentStr, `"}`)

			chatId := *event.Event.Message.ChatId
			log.Printf("[Feishu] 收到会话 %s 消息: %s\n", chatId, contentStr)

			go b.handleAgentRun(chatId, contentStr)
			return nil
		}).
		OnP2MessageReadV1(func(ctx context.Context, event *larkim.P2MessageReadV1) error {
			return nil
		})

	return handler
}

// Start 启动飞书 WebSocket 长连接客户端（阻塞当前 goroutine）
func (b *FeishuBot) Start(ctx context.Context) error {
	cli := larkws.NewClient(b.appID, b.appSecret,
		larkws.WithEventHandler(b.GetEventDispatcher()),
		larkws.WithLogLevel(larkcore.LogLevelDebug),
	)
	return cli.Start(ctx)
}

// handleAgentRun 是连接飞书与底层引擎的桥梁
func (b *FeishuBot) handleAgentRun(chatId string, prompt string) {
	reporter := &FeishuReporter{
		client: b.client,
		chatId: chatId,
	}

	workDir, _ := os.Getwd()
	session := ctxpkg.GlobalSessionMgr.GetOrCreate(chatId, workDir)
	session.Append(schema.Message{Role: schema.RoleUser, Content: prompt})

	err := b.engine.Run(context.Background(), session, reporter)
	if err != nil {
		reporter.sendMsg(fmt.Sprintf("❌ Agent 运行崩溃: %v", err))
	}
}

// ==========================================
// FeishuReporter: 将引擎的输出格式化后发给飞书
// ==========================================
type FeishuReporter struct {
	client *lark.Client
	chatId string
}

// sendMsg 封装了调用飞书 OpenAPI 发送卡片/文本的操作
func (r *FeishuReporter) sendMsg(text string) {
	// 构建文本消息内容
	textContent := map[string]string{
		"text": text,
	}
	contentBytes, _ := json.Marshal(textContent)
	contentStr := string(contentBytes)

	msgReq := larkim.NewCreateMessageReqBuilder().
		ReceiveIdType(larkim.CreateMessageV1ReceiveIDTypeChatId).
		Body(larkim.NewCreateMessageReqBodyBuilder().
			ReceiveId(r.chatId).
			MsgType(larkim.MsgTypeText).
			Content(contentStr).
			Build()).
		Build()

	_, _ = r.client.Im.Message.Create(context.Background(), msgReq)
}

func (r *FeishuReporter) OnThinking(ctx context.Context) {
	// 仅发一个轻量级提示，避免飞书刷屏
	r.sendMsg("🤔 模型正在慢思考 (Thinking)...")
}

func (r *FeishuReporter) OnToolCall(ctx context.Context, toolName string, args string) {
	r.sendMsg(fmt.Sprintf("🛠️ **正在执行工具**：`%s`\n参数：`%s`", toolName, args))
}

func (r *FeishuReporter) OnToolResult(ctx context.Context, toolName string, result string, isError bool) {
	if isError {
		r.sendMsg(fmt.Sprintf("⚠️ **执行报错** (%s)：\n%s", toolName, result))
	} else {
		// 成功时仅汇报成功，不刷全量日志
		r.sendMsg(fmt.Sprintf("✅ **执行成功** (%s)", toolName))
	}
}

func (r *FeishuReporter) OnMessage(ctx context.Context, content string) {
	// 将模型最终的纯文本回答发给用户
	r.sendMsg(content)
}

// 编译时类型检查：确保 FeishuReporter 实现了 Reporter 接口
var _ engine.Reporter = (*FeishuReporter)(nil)
