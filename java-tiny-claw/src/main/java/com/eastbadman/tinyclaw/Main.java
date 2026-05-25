package com.eastbadman.tinyclaw;

import com.eastbadman.tinyclaw.tools.BashTool;
import io.agentscope.core.ReActAgent;
import io.agentscope.core.memory.InMemoryMemory;
import io.agentscope.core.message.Msg;
import io.agentscope.core.model.OpenAIChatModel;
import io.agentscope.core.tool.Toolkit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * java-tiny-claw 入口
 *
 * 对应 go-tiny-claw 的 cmd/claw/main.go
 * 核心区别：AgentScope 框架已内置 ReAct 循环引擎、消息体系、工具调度，
 * 无需像 Go 版本那样手写 engine/loop.go、schema/message.go、tools/registry.go
 */
public class Main {

    private static final Logger log = LoggerFactory.getLogger(Main.class);

    public static void main(String[] args) {
        String workDir = System.getProperty("user.dir");
        log.info("引擎启动，锁定工作区: {}", workDir);

        // 1. 构建 LLM Provider（对应 go-tiny-claw 的 provider.LLMProvider）
        //    Go 版用 mock，这里接入真实 OpenAI 兼容 API
        String apiKey = System.getenv("OPENAI_API_KEY");
        String baseUrl = getEnvOrDefault("OPENAI_BASE_URL", "https://api.openai.com/v1");
        String modelName = getEnvOrDefault("MODEL_NAME", "gpt-4o");

        if (apiKey == null || apiKey.isBlank()) {
            log.error("请设置环境变量 OPENAI_API_KEY");
            System.exit(1);
        }

        OpenAIChatModel model = OpenAIChatModel.builder()
                .apiKey(apiKey)
                .modelName(modelName)
                .baseUrl(baseUrl)
                .stream(true)
                .build();

        // 2. 注册工具（对应 go-tiny-claw 的 tools.Registry）
        //    AgentScope 通过 @Tool 注解自动发现和注册，无需手写 registry
        Toolkit toolkit = new Toolkit();
        toolkit.registerTool(new BashTool());

        // 3. 构建 ReAct Agent（对应 go-tiny-claw 的 engine.AgentEngine）
        //    AgentScope 内置了完整的 ReAct 循环：Reasoning → Acting → Observation
        //    无需手写 loop.go 中的 for 循环
        ReActAgent agent = ReActAgent.builder()
                .name("java-tiny-claw")
                .sysPrompt("You are java-tiny-claw, an expert coding assistant. " +
                        "You have full access to tools in the workspace: " + workDir)
                .model(model)
                .toolkit(toolkit)
                .memory(new InMemoryMemory())
                .maxIters(10)
                .build();

        // 4. 发起任务（对应 go-tiny-claw 的 eng.Run()）
        Msg userMsg = Msg.builder()
                .textContent("帮我检查当前目录的文件")
                .build();

        log.info("开始执行任务...");
        Msg response = agent.call(userMsg).block();

        if (response != null) {
            System.out.println("\n🤖 Agent: " + response.getTextContent());
        }

        log.info("任务完成");
    }

    private static String getEnvOrDefault(String key, String defaultValue) {
        String value = System.getenv(key);
        return (value != null && !value.isBlank()) ? value : defaultValue;
    }
}
