# Example: Custom MCP Server for Project Context

This example demonstrates building a custom MCP server that provides project-specific context to GitHub Copilot.

## Overview

This MCP server provides:
- Project documentation access
- Architecture diagrams
- Code conventions
- Common patterns
- Team decisions and ADRs (Architecture Decision Records)

## Implementation

### TypeScript Implementation

```typescript
// project-context-mcp.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import fs from "fs/promises";
import path from "path";

interface ProjectContext {
  conventions: string;
  architecture: string;
  patterns: string[];
  decisions: string[];
}

class ProjectContextServer {
  private server: Server;
  private projectRoot: string;
  private context: ProjectContext | null = null;

  constructor(projectRoot: string) {
    this.projectRoot = projectRoot;
    
    this.server = new Server(
      {
        name: "project-context",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},
          tools: {},
        },
      }
    );

    this.setupHandlers();
  }

  private async loadProjectContext(): Promise<ProjectContext> {
    if (this.context) return this.context;

    const contextPath = path.join(this.projectRoot, ".copilot", "context");
    
    try {
      const conventions = await fs.readFile(
        path.join(contextPath, "conventions.md"),
        "utf-8"
      );
      
      const architecture = await fs.readFile(
        path.join(contextPath, "architecture.md"),
        "utf-8"
      );
      
      const patternsDir = path.join(contextPath, "patterns");
      const patternFiles = await fs.readdir(patternsDir);
      const patterns = await Promise.all(
        patternFiles.map(async (file) => {
          const content = await fs.readFile(
            path.join(patternsDir, file),
            "utf-8"
          );
          return content;
        })
      );
      
      const decisionsDir = path.join(contextPath, "decisions");
      const decisionFiles = await fs.readdir(decisionsDir);
      const decisions = await Promise.all(
        decisionFiles.map(async (file) => {
          const content = await fs.readFile(
            path.join(decisionsDir, file),
            "utf-8"
          );
          return content;
        })
      );

      this.context = {
        conventions,
        architecture,
        patterns,
        decisions,
      };

      return this.context;
    } catch (error) {
      throw new Error(`Failed to load project context: ${error.message}`);
    }
  }

  private setupHandlers() {
    // List available resources
    this.server.setRequestHandler(
      ListResourcesRequestSchema,
      async () => {
        await this.loadProjectContext();
        
        return {
          resources: [
            {
              uri: "project://conventions",
              name: "Code Conventions",
              description: "Project coding standards and conventions",
              mimeType: "text/markdown",
            },
            {
              uri: "project://architecture",
              name: "Architecture",
              description: "System architecture documentation",
              mimeType: "text/markdown",
            },
            {
              uri: "project://patterns",
              name: "Common Patterns",
              description: "Reusable code patterns used in this project",
              mimeType: "text/markdown",
            },
            {
              uri: "project://decisions",
              name: "Architecture Decisions",
              description: "ADRs and key technical decisions",
              mimeType: "text/markdown",
            },
          ],
        };
      }
    );

    // Read specific resources
    this.server.setRequestHandler(
      ReadResourceRequestSchema,
      async (request) => {
        const context = await this.loadProjectContext();
        const { uri } = request.params;

        let content: string;
        
        switch (uri) {
          case "project://conventions":
            content = context.conventions;
            break;
          case "project://architecture":
            content = context.architecture;
            break;
          case "project://patterns":
            content = context.patterns.join("\n\n---\n\n");
            break;
          case "project://decisions":
            content = context.decisions.join("\n\n---\n\n");
            break;
          default:
            throw new Error(`Unknown resource: ${uri}`);
        }

        return {
          contents: [
            {
              uri,
              mimeType: "text/markdown",
              text: content,
            },
          ],
        };
      }
    );

    // List available tools
    this.server.setRequestHandler(
      ListToolsRequestSchema,
      async () => {
        return {
          tools: [
            {
              name: "search_context",
              description: "Search project context for specific information",
              inputSchema: {
                type: "object",
                properties: {
                  query: {
                    type: "string",
                    description: "Search query",
                  },
                  scope: {
                    type: "string",
                    enum: ["all", "conventions", "architecture", "patterns", "decisions"],
                    description: "Scope to search in",
                  },
                },
                required: ["query"],
              },
            },
            {
              name: "get_pattern",
              description: "Get a specific code pattern by name",
              inputSchema: {
                type: "object",
                properties: {
                  pattern_name: {
                    type: "string",
                    description: "Name of the pattern to retrieve",
                  },
                },
                required: ["pattern_name"],
              },
            },
            {
              name: "check_convention",
              description: "Check if code follows project conventions",
              inputSchema: {
                type: "object",
                properties: {
                  code: {
                    type: "string",
                    description: "Code to check",
                  },
                  language: {
                    type: "string",
                    description: "Programming language",
                  },
                },
                required: ["code"],
              },
            },
          ],
        };
      }
    );

    // Handle tool calls
    this.server.setRequestHandler(
      CallToolRequestSchema,
      async (request) => {
        const { name, arguments: args } = request.params;

        switch (name) {
          case "search_context":
            return await this.searchContext(args.query, args.scope || "all");
          case "get_pattern":
            return await this.getPattern(args.pattern_name);
          case "check_convention":
            return await this.checkConvention(args.code, args.language);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      }
    );
  }

  private async searchContext(query: string, scope: string) {
    const context = await this.loadProjectContext();
    const results: string[] = [];
    
    const searchIn = (text: string, source: string) => {
      const lines = text.split("\n");
      const matches = lines.filter((line) =>
        line.toLowerCase().includes(query.toLowerCase())
      );
      
      if (matches.length > 0) {
        results.push(`### From ${source}:\n${matches.join("\n")}`);
      }
    };

    if (scope === "all" || scope === "conventions") {
      searchIn(context.conventions, "Conventions");
    }
    if (scope === "all" || scope === "architecture") {
      searchIn(context.architecture, "Architecture");
    }
    if (scope === "all" || scope === "patterns") {
      context.patterns.forEach((pattern, i) => {
        searchIn(pattern, `Pattern ${i + 1}`);
      });
    }
    if (scope === "all" || scope === "decisions") {
      context.decisions.forEach((decision, i) => {
        searchIn(decision, `Decision ${i + 1}`);
      });
    }

    return {
      content: [
        {
          type: "text",
          text: results.length > 0
            ? results.join("\n\n")
            : "No results found",
        },
      ],
    };
  }

  private async getPattern(patternName: string) {
    const context = await this.loadProjectContext();
    
    const pattern = context.patterns.find((p) =>
      p.toLowerCase().includes(patternName.toLowerCase())
    );

    if (!pattern) {
      return {
        content: [
          {
            type: "text",
            text: `Pattern "${patternName}" not found`,
          },
        ],
      };
    }

    return {
      content: [
        {
          type: "text",
          text: pattern,
        },
      ],
    };
  }

  private async checkConvention(code: string, language?: string) {
    const context = await this.loadProjectContext();
    
    // Simple convention checking (in reality, you'd use linters/analyzers)
    const violations: string[] = [];
    
    // Example checks
    if (language === "typescript" || language === "javascript") {
      if (code.includes("var ")) {
        violations.push("Use 'const' or 'let' instead of 'var'");
      }
      // Check for == that is not part of === or !==
      // This is a simplified check - in production, use a proper linter
      const hasLooseEquality = /(?<![=!])={2}(?!=)/g.test(code);
      if (hasLooseEquality) {
        violations.push("Use '===' instead of '=='");
      }
    }

    const result = violations.length === 0
      ? "✅ Code follows project conventions"
      : `⚠️ Convention violations found:\n${violations.map((v) => `- ${v}`).join("\n")}`;

    return {
      content: [
        {
          type: "text",
          text: result,
        },
      ],
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Project Context MCP Server running on stdio");
  }
}

// Start server
const projectRoot = process.argv[2] || process.cwd();
const server = new ProjectContextServer(projectRoot);
server.run().catch(console.error);
```

## Project Structure

```
.copilot/
  context/
    conventions.md
    architecture.md
    patterns/
      api-handler.md
      error-handling.md
      data-model.md
    decisions/
      001-use-typescript.md
      002-api-design.md
      003-database-choice.md
```

## Example Context Files

### conventions.md

```markdown
# Project Code Conventions

## General
- Use TypeScript for all new code
- Use ES modules (import/export)
- Enable strict mode
- Use async/await instead of callbacks

## Naming
- PascalCase for classes and types
- camelCase for variables and functions
- UPPER_SNAKE_CASE for constants
- Prefix interfaces with 'I' (e.g., IUserService)

## File Structure
- One export per file for classes
- Group related functions in modules
- Keep files under 300 lines

## Error Handling
- Use custom error classes
- Always catch and log errors
- Throw errors, don't return error codes
- Use try-catch for async operations

## Testing
- Write tests alongside code
- Aim for 80% coverage
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
```

### architecture.md

```markdown
# System Architecture

## Overview
Our system follows a layered architecture:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│         (API Controllers)           │
├─────────────────────────────────────┤
│         Business Logic Layer        │
│            (Services)               │
├─────────────────────────────────────┤
│         Data Access Layer           │
│         (Repositories)              │
├─────────────────────────────────────┤
│            Database                 │
└─────────────────────────────────────┘
```

## Key Principles
1. **Separation of Concerns**: Each layer has specific responsibilities
2. **Dependency Injection**: Use DI for all services
3. **Interface-Based**: Program to interfaces, not implementations
4. **Stateless Services**: Services should be stateless

## Data Flow
Request → Controller → Service → Repository → Database
```

### patterns/api-handler.md

```markdown
# API Handler Pattern

Use this pattern for all API endpoints:

\`\`\`typescript
export class UserController {
  constructor(private userService: IUserService) {}

  @Get('/users/:id')
  async getUser(req: Request, res: Response) {
    try {
      // 1. Validate input
      const userId = validateUserId(req.params.id);
      
      // 2. Call service
      const user = await this.userService.getUserById(userId);
      
      // 3. Handle not found
      if (!user) {
        return res.status(404).json({
          error: 'User not found'
        });
      }
      
      // 4. Return success response
      return res.status(200).json({
        data: user
      });
    } catch (error) {
      // 5. Handle errors
      if (error instanceof ValidationError) {
        return res.status(400).json({
          error: error.message
        });
      }
      
      // Log and return generic error
      logger.error('Error getting user:', error);
      return res.status(500).json({
        error: 'Internal server error'
      });
    }
  }
}
\`\`\`
```

## Configuration

Add to your Copilot configuration:

```json
{
  "mcpServers": {
    "project-context": {
      "command": "node",
      "args": ["/path/to/project-context-mcp.js", "${workspaceFolder}"]
    }
  }
}
```

## Usage in Copilot

Once configured, Copilot can access your project context:

```
@workspace Create a new API endpoint following our patterns

@workspace What are our error handling conventions?

@workspace Show me how to structure a service class

@workspace Check if this code follows our conventions:
[paste code]
```

## Benefits

1. **Consistent Code**: Copilot generates code following your conventions
2. **Onboarding**: New team members learn patterns through Copilot
3. **Documentation**: Context is always up-to-date and accessible
4. **Efficiency**: Reduces time explaining conventions

## Resources

- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Building MCP Servers Guide](https://modelcontextprotocol.io/docs)
