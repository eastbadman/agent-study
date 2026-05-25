package com.eastbadman.tinyclaw.tools;

import io.agentscope.core.tool.Tool;
import io.agentscope.core.tool.ToolParam;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 * Bash 工具：让 Agent 能够在本地执行 shell 命令
 * 对应 go-tiny-claw 中 mockRegistry 的真实实现
 */
public class BashTool {

    @Tool(name = "bash", description = "Execute a shell command and return its output. Use this to run system commands like ls, cat, grep, etc.")
    public String bash(
            @ToolParam(name = "command", description = "The shell command to execute", required = true)
            String command) {
        try {
            ProcessBuilder pb;
            String os = System.getProperty("os.name").toLowerCase();
            if (os.contains("win")) {
                pb = new ProcessBuilder("cmd", "/c", command);
            } else {
                pb = new ProcessBuilder("sh", "-c", command);
            }
            pb.redirectErrorStream(true);

            Process process = pb.start();
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }

            int exitCode = process.waitFor();
            if (exitCode != 0) {
                return "Command exited with code " + exitCode + "\n" + output;
            }
            return output.toString();
        } catch (Exception e) {
            return "Error executing command: " + e.getMessage();
        }
    }
}
