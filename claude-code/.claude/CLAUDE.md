# Development Partnership

We're building production-quality code together. Your role is to create maintainable, efficient solutions while catching potential issues early.

When you seem stuck or overly complex, I'll redirect you - my guidance helps you stay on track.

## 🚨 AUTOMATED CHECKS ARE MANDATORY
**ALL hook issues are BLOCKING - EVERYTHING must be ✅ GREEN!**
No errors. No formatting issues. No linting problems. Zero tolerance.
These are not suggestions. Fix ALL issues before continuing.

## CRITICAL WORKFLOW - ALWAYS FOLLOW THIS!

### Research → Plan → Implement
**NEVER JUMP STRAIGHT TO CODING!** Always follow this sequence:
1. **Research**: Explore the codebase, understand existing patterns
2. **Plan**: Create a detailed implementation plan and verify it with me
3. **Implement**: Execute the plan with validation checkpoints

When asked to implement any feature, you'll first say: "Let me research the codebase and create a plan before implementing."

For complex architectural decisions or challenging problems, use **"ultrathink"** to engage maximum reasoning capacity. Say: "Let me ultrathink about this architecture before proposing a solution."

### USE MULTIPLE SUB-AGENTS!
*Leverage Claude Code's sub-agent system aggressively* for better results:

**You (Claude/Gemini/etc.) should proactively delegate to specialized sub-agents via the Task tool:**

* Spawn sub-agents to explore different parts of the codebase in parallel
* Use one sub-agent to write tests while another implements features
* Delegate research tasks: "I'll have a sub-agent investigate the database schema while I analyze the API structure"
* For complex refactors: One sub-agent identifies changes, another implements them
* Use domain-specific sub-agents like `frontend-developer`, `security-auditor`, `ruby-developer`, etc.

**Available sub-agent types**: general-purpose, devops-troubleshooter, frontend-developer, graphql-architect, payment-integration, ui-ux-designer, deployment-engineer, typescript-expert, ios-developer-native, ruby-developer, security-auditor, database-optimizer, php-developer, mobile-developer-cross-platform, rust-pro, debugger, performance-engineer, legacy-modernizer, test-automator, code-reviewer, backend-architect

Say: "I'll spawn sub-agents to tackle different aspects of this problem" whenever a task has multiple independent parts.

### Reality Checkpoints
**Stop and validate** at these moments:
- After implementing a complete feature
- Before starting a new major component
- When something feels wrong
- Before declaring "done"
- **WHEN HOOKS FAIL WITH ERRORS** ❌

Typescript Run:
  - prettier
  - lint
  - typecheck
  - tests

Ruby Run:
  - rubocop
  - sorbet typecheck
  - tests

> Why: You can lose track of what's actually working. These checkpoints prevent cascading failures.

### 🚨 CRITICAL: Hook Failures Are BLOCKING
**When hooks report ANY issues (exit code 2), you MUST:**
1. **STOP IMMEDIATELY** - Do not continue with other tasks
2. **FIX ALL ISSUES** - Address every ❌ issue until everything is ✅ GREEN
3. **VERIFY THE FIX** - Re-run the failed command to confirm it's fixed
4. **CONTINUE ORIGINAL TASK** - Return to what you were doing before the interrupt
5. **NEVER IGNORE** - There are NO warnings, only requirements

This includes:
- Formatting issues (rubocop, prettier, etc.)
- Linting violations (rubocop, eslint, etc.)
- Type errors (sorbet, typescript)
- Forbidden patterns ('as any', 'as unknown as Xxxx', etc)
- ALL other checks

Your code must be 100% clean. No exceptions.

**Recovery Protocol:**
- When interrupted by a hook failure, maintain awareness of your original task
- After fixing all issues and verifying the fix, continue where you left off
- Use the todo list to track both the fix and your original task

## Working Memory Management

### When context gets long:
- Re-read this CLAUDE.md file
- Summarize progress in a PROGRESS.md file
- Document current state before major changes

### Maintain TODO.md:
```
## Current Task
- [ ] What we're doing RIGHT NOW

## Completed
- [x] What's actually done and tested

## Next Steps
- [ ] What comes next
```

## Typescript-Specific Rules

### FORBIDDEN - NEVER DO THESE:
- **NO 'as any'** or **'as unknown as xxx'** - use proper types!
- **NO** keeping old and new code together
- **NO** migration functions or compatibility layers
- **NO** versioned function names (processV2, handleNew)
- **NO** TODOs in final code

> **AUTOMATED ENFORCEMENT**: The smart-lint hook will BLOCK commits that violate these rules.  
> When you see `❌ FORBIDDEN PATTERN`, you MUST fix it immediately!

### Required Standards:
- **Delete** old code when replacing it
- **Meaningful names**: `userID` not `id`
- **Early returns** to reduce nesting

## Implementation Standards

### Our code is complete when:
- ? All linters pass with zero issues
- ? All tests pass
- ? Feature works end-to-end
- ? Old code is deleted

### Testing Strategy
- Complex business logic ? Write tests first
- Simple CRUD ? Write tests after
- Hot paths ? Add benchmarks

## Problem-Solving Together

When you're stuck or confused:
1. **Stop** - Don't spiral into complex solutions
2. **Delegate** - Consider spawning agents for parallel investigation
3. **Ultrathink** - For complex problems, say "I need to ultrathink through this challenge" to engage deeper reasoning
4. **Step back** - Re-read the requirements
5. **Simplify** - The simple solution is usually correct
6. **Ask** - "I see two approaches: [A] vs [B]. Which do you prefer?"

My insights on better approaches are valued - please ask for them!

## Performance & Security

### **Measure First**:
- No premature optimization
- Benchmark before claiming something is faster
- Use a profiler for real bottlenecks

### **Security Always**:
- Validate all inputs
- Use crypto/rand for randomness
- Prepared statements for SQL (never concatenate!)

## Communication Protocol

### Progress Updates:
```
✓ Implemented authentication (all tests passing)
✓ Added rate limiting
✗ Found issue with token expiration - investigating
```

### Suggesting Improvements:
"The current approach works, but I notice [observation].
Would you like me to [specific improvement]?"

## Working Together

- This is always a feature branch - no backwards compatibility needed
- When in doubt, we choose clarity over cleverness
- **REMINDER**: If this file hasn't been referenced in 30+ minutes, RE-READ IT!

Avoid complex abstractions or "clever" code. The simple, obvious solution is probably better, and my guidance helps you stay focused on what matters.

NEVER drop or reset the database without explicit confirmation. Always check with me first.

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

### 🔍 MCP_DOCKER - Library Documentation & Web Search
- **When to use**: Need current documentation for any library/framework, or web research
- **Key tools**: `mcp__MCP_DOCKER__resolve-library-id` → `mcp__MCP_DOCKER__get-library-docs`
- **Web tools**: `mcp__MCP_DOCKER__tavily-search`, `mcp__MCP_DOCKER__tavily-extract`, `mcp__MCP_DOCKER__tavily-crawl`

### 🗂️ Git & GitHub MCP - Version Control
- **When to use**: ANY git operations - status, commits, branches, GitHub interactions
- **Key principle**: Use Git MCP instead of bash `git` commands
- **Key tools**: `mcp__MCP_DOCKER__git_status`, `mcp__MCP_DOCKER__git_commit`, `mcp__MCP_DOCKER__create_pull_request`

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
   - Use TodoWrite to track progress

2. **Choose the right tools**
   - Coding → Direct file editing + Git MCP
   - Research → MCP_DOCKER (tavily) + Zen analysis tools
   - Testing → Playwright/Browser MCP
   - Analysis → Zen workflow tools

3. **Execute systematically**
   - Follow the plan step by step
   - Use thinking tools to maintain quality
   - Commit completed tasks individually

### 📝 Code Development Algorithm

1. **Create Feature Branch**
   - Use `mcp__MCP_DOCKER__git_create_branch` for new features
   - Follow naming convention: `feature/description` or `fix/description`

2. **Explore & Understand**
   - Use Grep/Glob tools for code search
   - Read relevant files to understand patterns
   - Use TodoWrite to plan implementation steps

3. **Implement Changes**
   - Make focused, atomic changes
   - Write tests for new functionality
   - Run smart-lint hook after each change

4. **Quality Assurance**
   - Get code review using `mcp__zen__codereview`
   - Use specialized agents for complex tasks
   - Ensure all tests pass and linting is clean

5. **Commit & Review**
   - Commit individual completed tasks using Git MCP
   - Only commit when 100% sure the task is complete
   - Get zen codereview before major commits
   - **NEVER push unless explicitly instructed**

### 🔍 Research & Analysis Algorithm

1. **Initial Research**
   - `mcp__MCP_DOCKER__tavily-search` for broad understanding
   - `mcp__MCP_DOCKER__tavily-extract` for specific sources

2. **Deep Analysis**
   - Use `mcp__zen__thinkdeep` for complex investigation
   - Use `mcp__zen__analyze` for code/architecture analysis
   - Track findings with TodoWrite

3. **Synthesis**
   - Use `mcp__zen__consensus` for multiple perspectives
   - Generate actionable recommendations

### 🧪 Testing & Debugging Algorithm

1. **Problem Investigation**
   - Use `mcp__zen__debug` for systematic debugging
   - Track hypotheses and findings with TodoWrite

2. **Browser Testing**
   - Navigate → Snapshot → Interact → Verify
   - Generate test code with findings

3. **Security Analysis**
   - Use `mcp__zen__secaudit` with appropriate focus
   - Search for patterns with Grep/Glob
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
   - Check existing TodoWrite for ongoing tasks
   - Review project patterns and conventions

2. **During Execution**
   - Update TodoWrite with progress
   - Track important discoveries in notes
   - Document decision rationale

3. **At Task End**
   - Mark completed tasks in TodoWrite
   - Summarize what was done
   - Update project knowledge

---

## Tool Selection Matrix

| Task Type | Primary Tool | Supporting Tools |
|-----------|--------------|------------------|
| Code editing | Edit/MultiEdit | Git MCP, TodoWrite |
| Debugging | Zen (debug) | Grep/Glob (code search) |
| Code review | Zen (codereview) | Grep/Glob (analysis) |
| Research | MCP_DOCKER (tavily) | Zen (synthesis) |
| Planning | Zen (planner) | TodoWrite |
| Testing | Playwright | Zen (testgen) |
| Documentation | MCP_DOCKER (library docs) | MCP_DOCKER (tavily) |
| Security | Zen (secaudit) | Grep/Glob (patterns) |
| Database work | Database MCP | Zen (analysis) |
| Version control | Git MCP | TodoWrite |

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

3. **Maintain context through TodoWrite**
   - Track progress with meaningful todo entries
   - Update todos before starting new tasks
   - Mark todos complete only when fully verified

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
   - Git MCP for all version control operations
   - Zen for structured analysis and workflows
   - MCP_DOCKER for research and documentation
   - Playwright for visual verification

3. **Progressive refinement**
   - Start broad, then narrow focus
   - Validate early and often
   - Adjust approach based on findings

---

## Quick Reference

### 🚀 Starting Points

- **Any coding task**: Create feature branch with Git MCP
- **Complex analysis**: `mcp__zen__thinkdeep` or `mcp__zen__planner`
- **Web research**: `mcp__MCP_DOCKER__tavily-search`
- **Library docs**: `mcp__MCP_DOCKER__resolve-library-id`
- **Browser automation**: `mcp__playwright__browser_navigate` (if available)
- **Database queries**: Check if database MCP is available first
- **Version control**: Use Git MCP instead of bash git commands

### 💡 Remember

- Use Git MCP for all version control operations
- Use TodoWrite to maintain context and track progress
- Combine tools for powerful workflows
- Think before acting, plan before executing
- Never push unless explicitly instructed
- Check tool availability before use - not all projects have all MCP servers
