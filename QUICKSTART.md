# Quick Start Guide

Get started with improving GitHub Copilot using agents, skills, and MCPs.

## For Complete Beginners

### What You Need

1. **GitHub Copilot** - Active subscription
2. **VS Code** or **Compatible IDE** - With Copilot extension installed
3. **Node.js** (optional) - For MCP servers

### Your First Steps

#### 1. Enable GitHub Copilot

1. Install GitHub Copilot extension in VS Code
2. Sign in with your GitHub account
3. Ensure Copilot is active (check status bar)

#### 2. Use Built-in Features

Start with basic Copilot features:

```javascript
// Type a comment describing what you want
// Generate a function that fetches user data from an API

// Copilot will suggest code for you
```

#### 3. Try Copilot Chat

Open Copilot Chat (Cmd/Ctrl + Shift + I) and ask:

```
@workspace Explain how this project is structured

Generate tests for the UserService class

Refactor this function to be more efficient
```

## Using Agents

### Quick Example: Code Review

1. **Add a comment in your PR**:
   ```
   @copilot Please review this code for potential issues
   ```

2. **In VS Code**, add comment:
   ```javascript
   // @copilot-review Check this function for bugs
   function processPayment(amount) {
     // your code
   }
   ```

3. **Copilot will analyze** and provide feedback

### Setting Up a Custom Agent

1. **Create agent config** (`.copilot/agents/reviewer.json`):
   ```json
   {
     "name": "code-reviewer",
     "instructions": "Review code for bugs and best practices",
     "tools": ["code_analyzer"]
   }
   ```

2. **Use the agent**:
   ```
   @code-reviewer Please review this file
   ```

## Using Skills

### Example: Generate CRUD Operations

1. **In VS Code**, type:
   ```typescript
   // @skill:crud-generator
   // Entity: Product
   // Fields: id, name, price, inStock
   ```

2. **Or use Copilot Chat**:
   ```
   Generate CRUD operations for a Product entity with id, name, price, and inStock fields
   ```

3. **Copilot generates**:
   - Create function
   - Read function
   - Update function
   - Delete function
   - Type definitions

### Common Skills to Try

1. **Test Generation**:
   ```
   @workspace Generate tests for this class
   ```

2. **API Client**:
   ```
   Generate an API client for the endpoints in api.yaml
   ```

3. **Documentation**:
   ```
   Add JSDoc comments to all functions in this file
   ```

## Using MCPs

### Quick Setup: Filesystem MCP

1. **Create config file** (`~/.config/Code/User/settings.json` or workspace `.vscode/settings.json`):
   ```json
   {
     "github.copilot.mcp": {
       "servers": {
         "filesystem": {
           "command": "npx",
           "args": [
             "-y",
             "@modelcontextprotocol/server-filesystem",
             "${workspaceFolder}"
           ]
         }
       }
     }
   }
   ```

2. **Reload VS Code**

3. **Ask Copilot**:
   ```
   @workspace What files are in the src directory?
   
   Read the contents of config.json and explain it
   ```

### Popular MCPs to Try

#### GitHub MCP

Access GitHub from Copilot:

```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token"
    }
  }
}
```

Then ask:
```
@workspace List open issues in this repository

What were the recent commits?
```

#### Memory MCP

Persistent context across sessions:

```json
{
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"]
  }
}
```

Use it:
```
@workspace Remember: This project uses PostgreSQL and Express

@workspace What database does this project use?
```

## Common Use Cases

### 1. Code Review Workflow

```
1. Write code
2. Ask: "@workspace Review this code for issues"
3. Fix issues
4. Ask: "@workspace Check if issues are fixed"
5. Commit
```

### 2. Test-Driven Development

```
1. Write test stub
2. Ask: "@workspace Complete this test"
3. Run test (should fail)
4. Ask: "@workspace Implement the function to make this test pass"
5. Run test (should pass)
```

### 3. Documentation

```
1. Write code
2. Ask: "@workspace Document all functions in this file"
3. Ask: "@workspace Create a README for this module"
4. Ask: "@workspace Generate API documentation"
```

### 4. Refactoring

```
1. Identify code smell
2. Ask: "@workspace Refactor this to follow SOLID principles"
3. Ask: "@workspace Add error handling"
4. Ask: "@workspace Optimize for performance"
```

### 5. Learning

```
Ask: "@workspace How does authentication work in this project?"

Ask: "@workspace Explain this algorithm step by step"

Ask: "@workspace What design patterns are used here?"
```

## Tips for Success

### 1. Be Specific

❌ Bad: "Fix this"
✅ Good: "Fix the null pointer exception in getUserById()"

### 2. Provide Context

❌ Bad: "Write tests"
✅ Good: "Write Jest tests for UserService.createUser() including error cases"

### 3. Iterate

Don't expect perfect results on first try:
1. Get initial suggestion
2. Refine with feedback
3. Iterate until satisfied

### 4. Use the Right Tool

- **Simple questions** → Copilot inline suggestions
- **Complex questions** → Copilot Chat
- **Code review** → Custom agent
- **Repetitive tasks** → Skills
- **External data** → MCPs

### 5. Learn from Suggestions

Pay attention to:
- Patterns Copilot uses
- Best practices it follows
- Solutions it proposes

## Troubleshooting

### Copilot Not Working

1. Check status bar - is Copilot active?
2. Restart VS Code
3. Check Copilot subscription
4. Check network connection

### MCPs Not Loading

1. Check configuration syntax
2. Verify command/path exists
3. Check environment variables
4. Look at Output panel (View → Output → GitHub Copilot)

### Poor Suggestions

1. Provide more context
2. Be more specific
3. Break down complex requests
4. Use comments to guide
5. Try rephrasing

## Next Steps

### Level Up Your Skills

1. **Read Documentation**
   - [Agents Guide](docs/AGENTS.md)
   - [Skills Guide](docs/SKILLS.md)
   - [MCP Guide](docs/MCP.md)

2. **Try Examples**
   - [Code Review Agent](examples/code-review-agent.md)
   - [Test Generation Skill](examples/test-generation-skill.md)
   - [Custom MCP Server](examples/custom-mcp-server.md)

3. **Create Your Own**
   - Start with simple agent
   - Build a custom skill
   - Develop an MCP for your workflow

4. **Share Back**
   - Contribute to this repo
   - Share your creations
   - Help others learn

## Resources

### Official

- [GitHub Copilot Docs](https://docs.github.com/en/copilot)
- [MCP Specification](https://modelcontextprotocol.io)
- [VS Code Copilot](https://code.visualstudio.com/docs/editor/artificial-intelligence)

### Community

- [GitHub Community](https://github.com/orgs/community/discussions/categories/copilot)
- [MCP Servers](https://github.com/modelcontextprotocol/servers)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/github-copilot)

### Learning

- [Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [Awesome GitHub Copilot](https://github.com/jmatthiesen/awesome-github-copilot)

---

**Ready to start?** Open VS Code and try your first Copilot command! 🚀
