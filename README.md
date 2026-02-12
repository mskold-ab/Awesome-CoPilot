# Awesome-CoPilot 🚀

A curated list of resources to improve and extend GitHub Copilot, including custom agents, skills, and Model Context Protocols (MCPs).

## Table of Contents

- [Agents](#agents)
- [Skills](#skills)
- [Model Context Protocols (MCPs)](#model-context-protocols-mcps)
- [Tools and Extensions](#tools-and-extensions)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [Resources](#resources)

## Agents

Custom agents are specialized AI assistants that can be configured to handle specific tasks within GitHub Copilot workflows.

### Development Agents

- **Code Review Agent** - Automated code review assistant that provides feedback on pull requests
  - Features: Style checking, security scanning, best practice recommendations
  - Use case: Automated PR reviews and code quality improvements

- **Testing Agent** - Generates and maintains test coverage
  - Features: Unit test generation, integration test scaffolding, test data creation
  - Use case: Improving test coverage and test quality

- **Documentation Agent** - Creates and updates documentation
  - Features: API documentation, README generation, inline code comments
  - Use case: Keeping documentation in sync with code changes

- **Refactoring Agent** - Identifies and performs code refactoring
  - Features: Code smell detection, pattern-based refactoring, dependency updates
  - Use case: Technical debt reduction and code modernization

### Domain-Specific Agents

- **Security Agent** - Focuses on security vulnerabilities and compliance
  - Features: Vulnerability scanning, security best practices, compliance checking
  - Use case: Security-focused code reviews and fixes

- **Performance Agent** - Optimizes code performance
  - Features: Performance profiling, bottleneck identification, optimization suggestions
  - Use case: Performance optimization and resource efficiency

- **Database Agent** - Database schema and query optimization
  - Features: Schema design, query optimization, migration generation
  - Use case: Database-related tasks and optimizations

### Creating Custom Agents

To create a custom agent:

1. Define the agent's purpose and scope
2. Configure the agent's system prompt and instructions
3. Specify available tools and capabilities
4. Set up agent triggers and workflows
5. Test and iterate on agent responses

Example agent configuration:
```json
{
  "name": "custom-agent",
  "description": "Description of what the agent does",
  "instructions": "System prompt and behavior guidelines",
  "tools": ["tool1", "tool2"],
  "triggers": ["on_pr", "on_issue"]
}
```

## Skills

Skills are reusable capabilities that can be leveraged across different Copilot interactions.

### Code Generation Skills

- **API Client Generation** - Generate API clients from OpenAPI/Swagger specs
- **Boilerplate Generation** - Create project scaffolding and common patterns
- **Data Model Generation** - Generate data models from schemas
- **CRUD Operations** - Generate standard CRUD operations for entities

### Code Analysis Skills

- **Dependency Analysis** - Analyze and manage project dependencies
- **Code Metrics** - Calculate complexity, maintainability metrics
- **Pattern Detection** - Identify common patterns and anti-patterns
- **Impact Analysis** - Assess impact of code changes

### Automation Skills

- **CI/CD Pipeline Generation** - Create deployment pipelines
- **Build Script Generation** - Generate build and deployment scripts
- **Configuration Management** - Manage configuration files and environment variables
- **Migration Scripts** - Generate database and data migration scripts

### Learning Skills

- **Code Explanation** - Explain code functionality and purpose
- **Best Practice Suggestions** - Recommend best practices for specific technologies
- **Example Generation** - Generate code examples and tutorials
- **Error Resolution** - Suggest fixes for common errors

### Developing Custom Skills

Skills can be developed as:
- Prompt templates
- Code snippets
- Tool integrations
- Workflow automations

Example skill definition:
```yaml
skill:
  name: "generate-api-client"
  description: "Generate API client from OpenAPI specification"
  inputs:
    - spec_url: string
    - language: string
  outputs:
    - client_code: string
  steps:
    - parse_openapi_spec
    - generate_types
    - generate_methods
    - format_output
```

## Model Context Protocols (MCPs)

MCPs enable structured communication between Copilot and external tools, services, and data sources.

### Core MCP Concepts

- **Resources** - Data sources that can be read (files, APIs, databases)
- **Tools** - Actions that can be performed (execute, transform, deploy)
- **Prompts** - Reusable prompt templates for common tasks
- **Sampling** - Request completions from language models

### Popular MCP Servers

#### Development MCPs

- **Filesystem MCP** - Access and manipulate local files
  - Operations: read, write, search, watch
  - Use case: File system operations and file management

- **Git MCP** - Interact with Git repositories
  - Operations: commit, branch, merge, diff
  - Use case: Version control operations

- **Database MCP** - Connect to databases
  - Operations: query, schema inspection, migrations
  - Use case: Database operations and data access

- **GitHub MCP** - Interact with GitHub API
  - Operations: issues, PRs, releases, actions
  - Use case: GitHub automation and integration

#### External Service MCPs

- **Slack MCP** - Integration with Slack
  - Operations: send messages, read channels, manage threads
  - Use case: Team communication and notifications

- **Jira MCP** - Project management integration
  - Operations: create issues, update status, search
  - Use case: Project tracking and task management

- **AWS MCP** - Cloud service integration
  - Operations: resource management, deployment, monitoring
  - Use case: Cloud infrastructure management

#### Specialized MCPs

- **Memory MCP** - Persistent memory across sessions
  - Operations: store, retrieve, search context
  - Use case: Maintaining context across conversations

- **Browser MCP** - Web automation and scraping
  - Operations: navigate, extract, interact
  - Use case: Web research and testing

- **Brave Search MCP** - Web search capabilities
  - Operations: search, summarize results
  - Use case: Finding current information

### Building Custom MCPs

Steps to create a custom MCP server:

1. **Define the protocol interface**
   ```typescript
   interface CustomMCP {
     resources: Resource[];
     tools: Tool[];
     prompts: Prompt[];
   }
   ```

2. **Implement resource handlers**
   ```typescript
   async function getResource(uri: string): Promise<Resource> {
     // Fetch and return resource
   }
   ```

3. **Implement tool handlers**
   ```typescript
   async function executeTool(name: string, args: any): Promise<any> {
     // Execute tool and return result
   }
   ```

4. **Set up MCP server**
   ```typescript
   const server = new MCPServer({
     name: "custom-mcp",
     version: "1.0.0"
   });
   ```

5. **Register with Copilot**
   ```json
   {
     "mcpServers": {
       "custom-mcp": {
         "command": "node",
         "args": ["path/to/server.js"]
       }
     }
   }
   ```

### MCP Configuration Examples

Example configuration for multiple MCPs:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/files"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "<YOUR_API_KEY>"
      }
    }
  }
}
```

## Tools and Extensions

### IDE Extensions

- **GitHub Copilot** - AI pair programmer
- **Copilot Chat** - Conversational AI assistance
- **Copilot CLI** - Command-line AI assistance
- **Copilot for Pull Requests** - AI-powered PR descriptions

### Complementary Tools

- **Prettier** - Code formatting
- **ESLint** - JavaScript/TypeScript linting
- **Ruff** - Python linting and formatting
- **CodeQL** - Security analysis
- **SonarQube** - Code quality analysis

### Integration Tools

- **GitHub Actions** - CI/CD automation
- **Pre-commit Hooks** - Git hooks for quality checks
- **VS Code Tasks** - Automated development tasks
- **Make/Task runners** - Build automation

## Best Practices

### Agent Best Practices

1. **Define Clear Scope** - Keep agents focused on specific tasks
2. **Provide Context** - Give agents sufficient context for decisions
3. **Iterate and Improve** - Continuously refine agent instructions
4. **Monitor Performance** - Track agent effectiveness and accuracy
5. **Handle Errors Gracefully** - Implement proper error handling

### Skill Development Best Practices

1. **Make Skills Reusable** - Design for reusability across projects
2. **Document Thoroughly** - Provide clear documentation and examples
3. **Test Extensively** - Validate skills across different scenarios
4. **Version Control** - Track changes and maintain compatibility
5. **Share with Community** - Contribute useful skills back

### MCP Best Practices

1. **Security First** - Validate inputs and manage credentials securely
2. **Error Handling** - Implement robust error handling
3. **Rate Limiting** - Respect API rate limits
4. **Logging** - Log operations for debugging
5. **Documentation** - Document available resources and tools

### Prompt Engineering Tips

1. **Be Specific** - Provide clear, specific instructions
2. **Provide Examples** - Include examples of desired output
3. **Use Context** - Reference relevant code and files
4. **Iterate** - Refine prompts based on results
5. **Break Down Tasks** - Split complex tasks into smaller steps

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-resource`)
3. **Add your resource** with proper documentation
4. **Submit a pull request** with a clear description

### Contribution Guidelines

- Ensure resources are relevant to GitHub Copilot improvements
- Provide clear descriptions and use cases
- Include examples where applicable
- Keep formatting consistent with existing content
- Verify all links are working

## Resources

### Official Documentation

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)
- [Copilot Extensibility](https://docs.github.com/en/copilot/building-copilot-extensions)

### Community Resources

- [Awesome GitHub Copilot](https://github.com/jmatthiesen/awesome-github-copilot)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [Copilot Community Forum](https://github.com/orgs/community/discussions/categories/copilot)

### Tutorials and Guides

- [Building Copilot Agents](https://docs.github.com/en/copilot/customizing-copilot/creating-custom-agents)
- [Creating MCP Servers](https://modelcontextprotocol.io/docs/getting-started)
- [Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)

### Tools and Libraries

- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [Copilot Extension SDK](https://docs.github.com/en/copilot/building-copilot-extensions/building-a-copilot-agent-for-your-copilot-extension)

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- GitHub Copilot Team
- Model Context Protocol Community
- Contributors to this awesome list

---

**Note**: This is a living document. As GitHub Copilot evolves, new resources and best practices will be added. Star this repository to stay updated!