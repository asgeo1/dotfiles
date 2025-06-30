# MCP Server Setup for Claude Code

This directory contains a script to manage MCP (Model Context Protocol) servers for use with Claude Code in your projects.

## Prerequisites

### Required Environment Variables
The following environment variables must be set before running the installation:
- `OPENAI_API_KEY` - For OpenAI integration
- `ANTHROPIC_API_KEY` - For Anthropic Claude integration
- `GOOGLE_CLOUD_PROJECT` - For Google Cloud services
- `TAVILY_API_KEY` - For Tavily web search

### Required Tools
- `uv`/`uvx` - Python package installer
- `npx` - Node.js package runner
- `claude` - Claude CLI

## Usage

### Installation Commands

```bash
# Interactive installation (default) - prompts for project type
mcp-setup install

# Install all servers explicitly (bypasses interactive prompt)
mcp-setup install --all

# Install specific servers
mcp-setup install serena
mcp-setup install serena zen context7

# Install for a specific project directory
mcp-setup install ~/Projects/myapp
mcp-setup install serena ~/Projects/myapp

# Install with profiles (predefined exclusions)
mcp-setup install --profile frontend    # Excludes database
mcp-setup install --profile backend     # Excludes browser, playwright
mcp-setup install --profile api         # Excludes browser, playwright
mcp-setup install --profile fullstack   # Installs everything

# Exclude specific servers
mcp-setup install --exclude database
mcp-setup install --exclude database,browser,playwright

# Non-interactive mode (useful for scripts/CI)
mcp-setup install --non-interactive
mcp-setup install -n --serena-project-name myapp-frontend
```

### Uninstallation Commands

```bash
# Uninstall specific servers
mcp-setup uninstall serena
mcp-setup uninstall serena zen

# Uninstall all servers
mcp-setup uninstall --all
```

### Other Commands

```bash
# Show status of installed servers
mcp-setup status

# Show help
mcp-setup help
```

## Available MCP Servers

| Server Key | Description | Notes | Common Exclusions |
|------------|-------------|-------|-------------------|
| `serena` | Code development and editing | Requires project-specific configuration | - |
| `context7` | Library documentation lookup | Quick access to documentation | - |
| `zen` | AI assistant tools and workflows | Complex analysis, planning, debugging | - |
| `tavily` | Web search and content extraction | Requires TAVILY_API_KEY | - |
| `browser` | Browser automation tools | Web interaction capabilities | Backend/API projects |
| `playwright` | Browser testing and automation | Advanced browser control | Backend/API projects |
| `database` | Database MCP (SQL Access) | Requires database URLs (PostgreSQL/MySQL) | Frontend projects |

## Installation Behavior

### Interactive Mode (Default)

When you run `mcp-setup install` without arguments, you'll be prompted to select your project type:

1. **Frontend project** - Excludes `database`
2. **Backend/API project** - Excludes `browser` and `playwright`
3. **Full-stack project** - Installs all servers
4. **Custom selection** - Choose specific servers manually
5. **Install all servers** - Install everything

This ensures you don't accidentally install unnecessary MCP servers for your project type.

### Project Profiles

You can also use profiles directly to skip the interactive prompt:

- **`--profile frontend`**: Installs all servers except `database`
- **`--profile backend`**: Installs all servers except `browser` and `playwright`
- **`--profile api`**: Installs all servers except `browser` and `playwright`
- **`--profile fullstack`**: Installs all servers

## Post-Installation

After successful installation:

### Serena Configuration

The installation process will prompt you for your desired project name. This is important because:
- The default is the directory name (e.g., "frontend"), which often isn't unique
- Monorepos often have generic directory names
- Multiple checkouts of the same repo need different project names

**How it works**:
1. During installation, you'll be prompted for a project name
2. Serena creates `.serena/project.yml` when first connected in Claude Code
3. If you chose a different name than the directory name, you'll need to manually update the config file

**Interactive mode** (default):
- You'll be prompted to enter a unique project name
- Press Enter to use the directory name as default

**Non-interactive mode** (for CI/CD):
```bash
mcp-setup install --non-interactive --serena-project-name myapp-frontend
```

**Activate in Claude Code**:
1. First run: "Read initial instructions"
2. Then run: "Activate the project [your-chosen-name]"
3. If needed, edit `.serena/project.yml` and update the project_name field

### Database Configuration

The database server supports both PostgreSQL and MySQL databases. Connection URL formats:
```
postgres://username:password@host:port/database_name
mysql://username:password@host:port/database_name
```

**Interactive mode**: When installing the database server, you'll be prompted to enter database URLs one at a time. Press Enter on an empty line when done.

**Non-interactive mode**:
```bash
# Use semicolons to separate multiple database URLs
mcp-setup install database -n --database-urls 'postgres://user:pass@localhost:5432/db1;mysql://user:pass@localhost:3306/db2'
```

**Mixed databases**: You can configure both PostgreSQL and MySQL databases in the same installation.

**Environment variable**: If `DB_CONFIGS` is already set in your environment, it will be used automatically.

**Security Note**: Database passwords are stored in Claude's MCP configuration. Ensure you're comfortable with this before proceeding.

### Other Servers
All other MCP servers (Context7, Zen, Tavily, Browser Tools, Playwright) are ready to use immediately without additional configuration.

## Troubleshooting

If installation fails:
1. Ensure all environment variables are set
2. Verify required tools are installed
3. Check network connectivity
4. Try installing individual servers using: `mcp-setup install serena`

### Common Issues

- **"Unknown server" error**: Check available server names with `mcp-setup help`
- **Environment variable errors**: Source your shell config or export variables in current session
- **Tool not found**: Install missing tools as shown in error messages