# MSkold - Awesome-CoPilot 

A collection of specialized GitHub Copilot agents for various development tasks.

## Available Agents

### Azure DevOps Extension Developer
[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](vscode:chat-agent/install?url=https://raw.githubusercontent.com/mskold-ab/Awesome-CoPilot/refs/heads/main/agents/Modern%20Extension%20Developer?token=GHSAT0AAAAAADTKZYPEUFLO4PMI255IVGS62MN4QDA)<br />
Expert agent for developing Azure DevOps extensions, including:
<a href="https://www.dn.se">test</a>
- Web extensions and UI contributions
- Custom build and release tasks
- Service hooks and webhooks
- Work item tracking extensions
- REST API integration

**Location:** `.github/agents/azure-devops-extension-developer.yml`

**Expertise:**
- TypeScript/JavaScript development
- Azure DevOps Extension SDK
- VSS Web Extension SDK
- Pipeline task development
- Extension packaging and publishing

## Using These Agents

These agents are custom GitHub Copilot agents that can be used in repositories that have GitHub Copilot enabled. To use an agent:

1. Ensure your repository has GitHub Copilot enabled
2. Reference the agent in your `.github/agents/` directory
3. Invoke the agent through GitHub Copilot's interface

## Contributing

To add a new agent:
1. Create a new YAML file in `.github/agents/`
2. Define the agent's name, description, and instructions
3. Update this README with the agent information
