# Model Context Protocol (MCP) Guide

## What is MCP?

The Model Context Protocol (MCP) is an open protocol that standardizes how applications provide context to Large Language Models (LLMs). It enables secure, controlled access to data and tools through a client-server architecture.

## Core Concepts

### Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   Client    │◄────►│ MCP Server   │◄────►│  Resources  │
│  (Copilot)  │      │  (Protocol)  │      │   & Tools   │
└─────────────┘      └──────────────┘      └─────────────┘
```

### Key Components

1. **Resources** - Data sources that can be read
2. **Tools** - Actions that can be executed
3. **Prompts** - Reusable prompt templates
4. **Sampling** - Request LLM completions

## MCP Server Types

### 1. Filesystem MCP

Access local files and directories securely.

**Capabilities:**
- Read file contents
- List directory contents
- Search files
- Watch for changes

**Configuration:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/allowed/path"],
      "env": {}
    }
  }
}
```

**Usage Example:**
```javascript
// Read a file
const content = await mcp.readResource("file:///path/to/file.js");

// List directory
const files = await mcp.readResource("file:///path/to/dir/");

// Search files
const results = await mcp.callTool("search", {
  path: "/path/to/search",
  pattern: "*.ts"
});
```

### 2. Git MCP

Interact with Git repositories.

**Capabilities:**
- Read commit history
- View diffs
- Check status
- Read file contents at specific commits

**Configuration:**
```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git", "/path/to/repo"]
    }
  }
}
```

**Usage Example:**
```javascript
// Get commit log
const commits = await mcp.callTool("git_log", {
  max_count: 10
});

// Get file diff
const diff = await mcp.callTool("git_diff", {
  file: "src/app.js"
});

// Get commit details
const commit = await mcp.readResource("git://commit/abc123");
```

### 3. GitHub MCP

Integrate with GitHub API.

**Capabilities:**
- Read repositories
- Access issues and PRs
- Read file contents
- Search code
- Manage workflows

**Configuration:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<token>"
      }
    }
  }
}
```

**Usage Example:**
```javascript
// Get repository info
const repo = await mcp.readResource("github://owner/repo");

// List issues
const issues = await mcp.callTool("list_issues", {
  owner: "owner",
  repo: "repo",
  state: "open"
});

// Get PR details
const pr = await mcp.readResource("github://owner/repo/pull/123");
```

### 4. Database MCPs

Connect to various databases.

#### PostgreSQL MCP

**Configuration:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "PGHOST": "localhost",
        "PGPORT": "5432",
        "PGDATABASE": "mydb",
        "PGUSER": "user",
        "PGPASSWORD": "password"
      }
    }
  }
}
```

**Usage Example:**
```javascript
// Query database
const results = await mcp.callTool("query", {
  sql: "SELECT * FROM users WHERE active = true"
});

// Get schema
const schema = await mcp.readResource("postgres://schema/public");
```

### 5. Web MCPs

#### Browser MCP

Automate web interactions.

**Capabilities:**
- Navigate to URLs
- Extract content
- Take screenshots
- Interact with elements

**Configuration:**
```json
{
  "mcpServers": {
    "browser": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

#### Brave Search MCP

Perform web searches.

**Configuration:**
```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "<api-key>"
      }
    }
  }
}
```

**Usage Example:**
```javascript
// Web search
const results = await mcp.callTool("brave_web_search", {
  query: "TypeScript best practices",
  count: 10
});
```

### 6. Communication MCPs

#### Slack MCP

Integrate with Slack.

**Capabilities:**
- Send messages
- Read channels
- Manage threads
- Upload files

**Configuration:**
```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "<token>"
      }
    }
  }
}
```

### 7. Cloud MCPs

#### AWS MCP

Manage AWS resources.

**Capabilities:**
- List resources
- Deploy infrastructure
- Manage S3 buckets
- Lambda functions

**Configuration:**
```json
{
  "mcpServers": {
    "aws": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-aws"],
      "env": {
        "AWS_ACCESS_KEY_ID": "<key>",
        "AWS_SECRET_ACCESS_KEY": "<secret>",
        "AWS_REGION": "us-east-1"
      }
    }
  }
}
```

### 8. Development Tool MCPs

#### Memory MCP

Persistent context across sessions.

**Capabilities:**
- Store key-value pairs
- Retrieve context
- Search memory
- Organize by namespace

**Configuration:**
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

**Usage Example:**
```javascript
// Store context
await mcp.callTool("store_memory", {
  key: "project_context",
  value: "Working on authentication feature"
});

// Retrieve context
const context = await mcp.callTool("get_memory", {
  key: "project_context"
});
```

## Building Custom MCP Servers

### Basic Server Structure

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

// Create server
const server = new Server(
  {
    name: "custom-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      resources: {},
      tools: {},
      prompts: {},
    },
  }
);

// Define resources
server.setRequestHandler(
  "resources/list",
  async () => {
    return {
      resources: [
        {
          uri: "custom://resource/1",
          name: "Resource 1",
          description: "Description",
          mimeType: "text/plain"
        }
      ]
    };
  }
);

// Define tools
server.setRequestHandler(
  "tools/list",
  async () => {
    return {
      tools: [
        {
          name: "custom_tool",
          description: "Description of tool",
          inputSchema: {
            type: "object",
            properties: {
              param1: { type: "string" }
            },
            required: ["param1"]
          }
        }
      ]
    };
  }
);

// Handle tool calls
server.setRequestHandler(
  "tools/call",
  async (request) => {
    const { name, arguments: args } = request.params;
    
    if (name === "custom_tool") {
      // Execute tool logic
      const result = await executeCustomTool(args);
      
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(result)
          }
        ]
      };
    }
    
    throw new Error(`Unknown tool: ${name}`);
  }
);

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Python MCP Server

```python
from mcp.server import Server, NotificationOptions
from mcp.server.models import InitializationOptions
import mcp.server.stdio
import mcp.types as types

# Create server
server = Server("custom-mcp")

# Define resources
@server.list_resources()
async def handle_list_resources() -> list[types.Resource]:
    return [
        types.Resource(
            uri="custom://resource/1",
            name="Resource 1",
            description="Description",
            mimeType="text/plain"
        )
    ]

# Define tools
@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="custom_tool",
            description="Description of tool",
            inputSchema={
                "type": "object",
                "properties": {
                    "param1": {"type": "string"}
                },
                "required": ["param1"]
            }
        )
    ]

# Handle tool calls
@server.call_tool()
async def handle_call_tool(
    name: str,
    arguments: dict
) -> list[types.TextContent]:
    if name == "custom_tool":
        result = await execute_custom_tool(arguments)
        return [
            types.TextContent(
                type="text",
                text=str(result)
            )
        ]
    
    raise ValueError(f"Unknown tool: {name}")

# Run server
async def main():
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="custom-mcp",
                server_version="1.0.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                )
            )
        )
```

### Advanced Features

#### Resource Templates

```typescript
// Dynamic resources
server.setRequestHandler(
  "resources/read",
  async (request) => {
    const { uri } = request.params;
    
    // Parse URI
    const match = uri.match(/^custom:\/\/(\w+)\/(.+)$/);
    if (!match) {
      throw new Error("Invalid URI");
    }
    
    const [, type, id] = match;
    
    // Fetch resource
    const data = await fetchResource(type, id);
    
    return {
      contents: [
        {
          uri,
          mimeType: "application/json",
          text: JSON.stringify(data)
        }
      ]
    };
  }
);
```

#### Prompts

```typescript
server.setRequestHandler(
  "prompts/list",
  async () => {
    return {
      prompts: [
        {
          name: "code_review",
          description: "Review code for issues",
          arguments: [
            {
              name: "code",
              description: "Code to review",
              required: true
            }
          ]
        }
      ]
    };
  }
);

server.setRequestHandler(
  "prompts/get",
  async (request) => {
    const { name, arguments: args } = request.params;
    
    if (name === "code_review") {
      return {
        messages: [
          {
            role: "user",
            content: {
              type: "text",
              text: `Review this code:\n\n${args.code}`
            }
          }
        ]
      };
    }
  }
);
```

## MCP Best Practices

### 1. Security

```typescript
// Validate inputs
function validateInput(input: unknown): void {
  if (typeof input !== "string") {
    throw new Error("Invalid input type");
  }
  
  // Sanitize paths
  const normalized = path.normalize(input);
  if (normalized.includes("..")) {
    throw new Error("Path traversal detected");
  }
}

// Use environment variables for secrets
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error("API_KEY not configured");
}
```

### 2. Error Handling

```typescript
server.setRequestHandler(
  "tools/call",
  async (request) => {
    try {
      const result = await executeTool(request.params);
      return { content: [{ type: "text", text: result }] };
    } catch (error) {
      // Log error
      console.error("Tool execution failed:", error);
      
      // Return user-friendly error
      return {
        content: [
          {
            type: "text",
            text: `Error: ${error.message}`
          }
        ],
        isError: true
      };
    }
  }
);
```

### 3. Rate Limiting

```typescript
import { RateLimiter } from "limiter";

const limiter = new RateLimiter({
  tokensPerInterval: 10,
  interval: "minute"
});

server.setRequestHandler(
  "tools/call",
  async (request) => {
    // Check rate limit
    const hasToken = await limiter.removeTokens(1);
    if (!hasToken) {
      throw new Error("Rate limit exceeded");
    }
    
    // Execute tool
    return await executeTool(request.params);
  }
);
```

### 4. Logging

```typescript
import winston from "winston";

const logger = winston.createLogger({
  level: "info",
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: "mcp.log" })
  ]
});

server.setRequestHandler(
  "tools/call",
  async (request) => {
    logger.info("Tool called", {
      tool: request.params.name,
      args: request.params.arguments
    });
    
    const result = await executeTool(request.params);
    
    logger.info("Tool completed", {
      tool: request.params.name,
      success: true
    });
    
    return result;
  }
);
```

### 5. Testing

```typescript
import { describe, it, expect } from "vitest";

describe("Custom MCP Server", () => {
  it("lists resources", async () => {
    const response = await server.request({
      method: "resources/list"
    });
    
    expect(response.resources).toHaveLength(1);
    expect(response.resources[0].uri).toBe("custom://resource/1");
  });
  
  it("executes tools", async () => {
    const response = await server.request({
      method: "tools/call",
      params: {
        name: "custom_tool",
        arguments: { param1: "value" }
      }
    });
    
    expect(response.content).toBeDefined();
  });
});
```

## Integration Examples

### VS Code Configuration

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${workspaceFolder}"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
      }
    },
    "custom": {
      "command": "node",
      "args": ["${workspaceFolder}/mcp/custom-server.js"]
    }
  }
}
```

### Claude Desktop Configuration

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "<api-key>"
      }
    }
  }
}
```

## Resources

- [MCP Specification](https://modelcontextprotocol.io/docs)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [Official MCP Servers](https://github.com/modelcontextprotocol/servers)
- [MCP Documentation](https://modelcontextprotocol.io)
