# Important Long-Term Memory notes

- Never under any circumstances, ever, EVER use 'as any' in TypeScript code. Always use or import/find the correct type.

---

# MCP Tools Guide

This guide provides strategic guidance on when and how to use MCP tools effectively.

## IMPORTANT: Project-Specific Tool Availability

**Not all MCP tools listed below may be available for the current project.** The available tools depend on which MCP servers were installed for this specific project:

- **Frontend projects** typically exclude: `database`
- **Backend/API projects** typically exclude: `browser`, `playwright`
- **Full-stack projects** typically include all tools

To check which MCP tools are actually available in the current project, look for error messages when attempting to use a tool, or check the project's MCP configuration.

## Tool Categories

### 🔍 Context7 - Library Documentation
- **When to use**: Need current documentation for any library/framework
- **Key tools**: `resolve-library-id` → `get-library-docs`

### 🌐 Tavily - Web Search & Analysis  
- **When to use**: Current information, documentation, best practices, or web content analysis
- **Key tools**: `search`, `extract`, `crawl`, `map`

### 💻 Serena - Code Development
- **When to use**: ANY coding task - editing, refactoring, debugging, or analyzing code
- **Getting started**: ALWAYS run `mcp__serena__initial_instructions` first
- **Key principle**: Prefer symbolic operations over text operations

### 🤖 Zen - AI Assistant Tools
- **When to use**: Complex analysis, planning, consensus building, or structured workflows
- **Key tools**: `chat`, `thinkdeep`, `planner`, `consensus`, workflow tools (`codereview`, `debug`, `secaudit`, etc.)

### 🎭 Playwright/Browser MCP - Browser Automation
- **When to use**: Web testing, scraping, automation, or visual verification
- **Key principle**: Always snapshot before interacting
- **Common exclusion**: Backend/API projects

### 🗄️ Database MCP - SQL Database Access
- **When to use**: Direct SQL database queries, schema inspection, data analysis
- **Key tools**: Query execution, schema exploration, data manipulation
- **Common exclusion**: Frontend projects
- **Note**: Requires database connection URLs configured during installation

---

## Planning & Execution Algorithms

### 🎯 General Planning Algorithm

1. **Understand the request**
   - Use `mcp__zen__planner` for complex multi-step tasks
   - Break down into concrete, achievable steps
   - Store plan in memory using `mcp__serena__write_memory`

2. **Choose the right tools**
   - Coding → Serena (start with `initial_instructions`)
   - Research → Tavily + Zen analysis tools
   - Testing → Playwright/Browser MCP
   - Analysis → Zen workflow tools

3. **Execute systematically**
   - Follow the plan step by step
   - Update memory with progress and findings
   - Use thinking tools to maintain quality

### 📝 Code Development Algorithm

1. **Initialize**
   ```
   mcp__serena__initial_instructions
   mcp__serena__check_onboarding_performed
   ```

2. **Explore & Understand**
   - Use `find_symbol` for targeted search
   - Use `get_symbols_overview` for structure understanding
   - Read relevant files with context

3. **Plan Changes**
   - `mcp__serena__think_about_collected_information`
   - Write plan to memory
   - `mcp__serena__think_about_task_adherence`

4. **Execute Changes**
   - Prefer `replace_symbol_body` over text replacement
   - Use `insert_before/after_symbol` for additions
   - Run tests/lints after changes

5. **Finalize**
   - `mcp__serena__think_about_whether_you_are_done`
   - `mcp__serena__summarize_changes`
   - Update memory with what was done

### 🔍 Research & Analysis Algorithm

1. **Initial Research**
   - `mcp__tavily__tavily-search` for broad understanding
   - `mcp__tavily__tavily-extract` for specific sources

2. **Deep Analysis**
   - Use `mcp__zen__thinkdeep` for complex investigation
   - Use `mcp__zen__analyze` for code/architecture analysis
   - Store findings in memory

3. **Synthesis**
   - Use `mcp__zen__consensus` for multiple perspectives
   - Generate actionable recommendations

### 🧪 Testing & Debugging Algorithm

1. **Problem Investigation**
   - Use `mcp__zen__debug` for systematic debugging
   - Track hypotheses and findings in memory

2. **Browser Testing**
   - Navigate → Snapshot → Interact → Verify
   - Generate test code with findings

3. **Security Analysis**
   - Use `mcp__zen__secaudit` with appropriate focus
   - Search for patterns with Serena
   - Document vulnerabilities

---

## Memory Management Strategy

### 📚 What to Store in Memory

1. **Project Context**
   - Architecture decisions
   - Key patterns and conventions
   - Important file locations
   - Build/test commands

2. **Task Progress**
   - Current plan and status
   - Completed steps
   - Blockers and decisions
   - Key findings

3. **Learning & Insights**
   - Discovered patterns
   - Problem solutions
   - Performance considerations
   - Security notes

### 🔄 Memory Workflow

1. **At Task Start**
   ```
   mcp__serena__list_memories
   mcp__serena__read_memory (relevant ones)
   ```

2. **During Execution**
   - Update plan progress
   - Store important discoveries
   - Track decision rationale

3. **At Task End**
   - Summarize what was done
   - Store reusable patterns
   - Update project knowledge

---

## Tool Selection Matrix

| Task Type | Primary Tool | Supporting Tools |
|-----------|--------------|------------------|
| Code editing | Serena | Zen (analysis) |
| Debugging | Zen (debug) | Serena (code search) |
| Code review | Zen (codereview) | Serena (analysis) |
| Research | Tavily | Zen (synthesis) |
| Planning | Zen (planner) | Serena (memory) |
| Testing | Playwright | Zen (testgen) |
| Documentation | Context7 | Tavily (examples) |
| Security | Zen (secaudit) | Serena (patterns) |
| Database work | Database MCP | Zen (analysis) |

---

## Best Practices

### 🎯 General Principles

1. **Always plan before executing**
   - Use appropriate planning tools
   - Store plans in memory
   - Update plans as you learn

2. **Use the right tool for the job**
   - Don't use basic tools when specialized ones exist
   - Combine tools for best results
   - Follow tool-specific best practices

3. **Maintain context through memory**
   - Write meaningful memory entries
   - Read relevant memories before starting
   - Update memories with learnings

4. **Think systematically**
   - Use thinking tools at key decision points
   - Validate assumptions before proceeding
   - Document rationale for future reference

### ⚡ Efficiency Tips

1. **Batch operations**
   - Group related searches/edits
   - Use symbolic operations for multiple changes
   - Plan comprehensively to avoid rework

2. **Leverage tool strengths**
   - Serena for language-aware editing
   - Zen for structured analysis
   - Tavily for current information
   - Playwright for visual verification

3. **Progressive refinement**
   - Start broad, then narrow focus
   - Validate early and often
   - Adjust approach based on findings

---

## Quick Reference

### 🚀 Starting Points

- **Any coding task**: `mcp__serena__initial_instructions`
- **Complex analysis**: `mcp__zen__thinkdeep` or `mcp__zen__planner`
- **Web research**: `mcp__tavily__tavily-search`
- **Library docs**: `mcp__context7__resolve-library-id`
- **Browser automation**: `mcp__playwright__browser_navigate` (if available)
- **Database queries**: Check if database MCP is available first

### 💡 Remember

- Serena's `initial_instructions` contains comprehensive coding guidance
- Use memory to maintain context across sessions
- Combine tools for powerful workflows
- Think before acting, plan before executing
- Check tool availability before use - not all projects have all MCP servers
