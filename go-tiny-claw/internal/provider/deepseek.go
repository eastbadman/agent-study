package provider

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/eastbadman/agent-study/go-tiny-claw/internal/schema"
)

// DeepSeekProvider 基于 OpenAI 兼容协议对接 DeepSeek（使用原始 HTTP 以正确处理 reasoning_content）
type DeepSeekProvider struct {
	apiKey  string
	model   string
	baseURL string
	client  *http.Client
}

func NewDeepSeekProvider(apiKey, model, baseURL string) *DeepSeekProvider {
	return &DeepSeekProvider{
		apiKey:  apiKey,
		model:   model,
		baseURL: baseURL,
		client:  &http.Client{},
	}
}

// requestBody 是发送给 DeepSeek API 的请求体结构
type requestBody struct {
	Model    string        `json:"model"`
	Messages []any         `json:"messages"`
	Tools    []toolDefJSON `json:"tools,omitempty"`
}

type toolDefJSON struct {
	Type     string         `json:"type"`
	Function functionDefJSON `json:"function"`
}

type functionDefJSON struct {
	Name        string         `json:"name"`
	Description string         `json:"description,omitempty"`
	Parameters  map[string]any `json:"parameters,omitempty"`
}

// apiResponse 是 DeepSeek API 的响应结构
type apiResponse struct {
	Choices []struct {
		Message struct {
			Role             string `json:"role"`
			Content          string `json:"content"`
			ReasoningContent any    `json:"reasoning_content"`
			ToolCalls        []struct {
				ID       string `json:"id"`
				Type     string `json:"type"`
				Function struct {
					Name      string `json:"name"`
					Arguments string `json:"arguments"`
				} `json:"function"`
			} `json:"tool_calls"`
		} `json:"message"`
	} `json:"choices"`
	Error *struct {
		Message string `json:"message"`
	} `json:"error"`
}

func (p *DeepSeekProvider) Generate(ctx context.Context, msgs []schema.Message, availableTools []schema.ToolDefinition) (*schema.Message, error) {
	// 1. 构建消息列表，确保 reasoning_content 原样回传
	var messages []any
	for _, msg := range msgs {
		switch msg.Role {
		case schema.RoleSystem:
			messages = append(messages, map[string]any{
				"role":    "system",
				"content": msg.Content,
			})

		case schema.RoleUser:
			if msg.ToolCallID != "" {
				messages = append(messages, map[string]any{
					"role":         "tool",
					"content":      msg.Content,
					"tool_call_id": msg.ToolCallID,
				})
			} else {
				messages = append(messages, map[string]any{
					"role":    "user",
					"content": msg.Content,
				})
			}

		case schema.RoleAssistant:
			m := map[string]any{
				"role": "assistant",
			}
			if msg.Content != "" {
				m["content"] = msg.Content
			}
			if msg.HasReasoningContent {
				m["reasoning_content"] = msg.ReasoningContent
			}
			if len(msg.ToolCalls) > 0 {
				var toolCalls []map[string]any
				for _, tc := range msg.ToolCalls {
					toolCalls = append(toolCalls, map[string]any{
						"id":   tc.ID,
						"type": "function",
						"function": map[string]any{
							"name":      tc.Name,
							"arguments": string(tc.Arguments),
						},
					})
				}
				m["tool_calls"] = toolCalls
			}
			messages = append(messages, m)
		}
	}

	// 2. 构建工具定义
	var tools []toolDefJSON
	for _, toolDef := range availableTools {
		var params map[string]any
		if m, ok := toolDef.InputSchema.(map[string]interface{}); ok {
			params = m
		} else {
			b, _ := json.Marshal(toolDef.InputSchema)
			_ = json.Unmarshal(b, &params)
		}
		tools = append(tools, toolDefJSON{
			Type: "function",
			Function: functionDefJSON{
				Name:        toolDef.Name,
				Description: toolDef.Description,
				Parameters:  params,
			},
		})
	}

	// 3. 构建请求体
	reqBody := requestBody{
		Model:    p.model,
		Messages: messages,
		Tools:    tools,
	}

	bodyBytes, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("序列化请求体失败: %w", err)
	}

	// 4. 发送 HTTP 请求
	url := p.baseURL + "/chat/completions"
	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewReader(bodyBytes))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("DeepSeek API 请求失败: %w", err)
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("DeepSeek API 请求失败: %s %s", resp.Status, string(respBytes))
	}

	// 5. 解析响应
	var apiResp apiResponse
	if err := json.Unmarshal(respBytes, &apiResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}

	if apiResp.Error != nil {
		return nil, fmt.Errorf("DeepSeek API 错误: %s", apiResp.Error.Message)
	}

	if len(apiResp.Choices) == 0 {
		return nil, fmt.Errorf("DeepSeek API 返回了空的 Choices")
	}

	choice := apiResp.Choices[0].Message
	resultMsg := &schema.Message{
		Role:    schema.RoleAssistant,
		Content: choice.Content,
	}

	// 提取 reasoning_content（保留原始值：字符串或 null）
	if choice.ReasoningContent != nil {
		resultMsg.HasReasoningContent = true
		if s, ok := choice.ReasoningContent.(string); ok {
			resultMsg.ReasoningContent = s
		}
	}

	for _, tc := range choice.ToolCalls {
		if tc.Type == "function" {
			resultMsg.ToolCalls = append(resultMsg.ToolCalls, schema.ToolCall{
				ID:        tc.ID,
				Name:      tc.Function.Name,
				Arguments: []byte(tc.Function.Arguments),
			})
		}
	}

	return resultMsg, nil
}
