# AirAI + Cline Integration Guide

Use AirAI CLI and Cline together for the ultimate air-gapped AI coding experience.

## Overview

Combine the strengths of both tools:

**AirAI CLI** - Infrastructure & Quick Tasks
- Server management
- Model operations  
- Quick code queries
- File editing
- Code review
- Container deployment

**Cline (VS Code)** - Full AI Coding Assistant
- Interactive chat interface
- Context-aware assistance
- Multi-file editing
- Visual diff previews
- IDE integration
- Debugging support

## Architecture

```
┌──────────────────────────────────────────────┐
│           Developer Workstation              │
│  ┌─────────────┐         ┌───────────────┐  │
│  │  Terminal   │         │   VS Code     │  │
│  │  (AirAI)    │         │   + Cline     │  │
│  └──────┬──────┘         └───────┬───────┘  │
└─────────┼─────────────────────────┼──────────┘
          │                         │
          └────────┬────────────────┘
                   │ HTTP API
                   ▼
     ┌─────────────────────────────┐
     │   Ollama Server :11434      │
     │   - Qwen 2.5 Coder 32B      │
     │   - DeepSeek R1 32B         │
     │   - Qwen 2.5 Coder 14B      │
     └─────────────────────────────┘
```

## Setup Guide

### Step 1: Install Ollama Server

Choose your deployment method:

**Option A: Container (Recommended)**
```bash
# Build and run
./scripts/container/build.sh
./scripts/container/run.sh
```

**Option B: Traditional**
```bash
# Install from air-gap package
cd scripts/installation/server
sudo ./install-ubuntu.sh ~/airgap-package
```

### Step 2: Install AirAI CLI

```bash
# From source
pip install -e .

# Or from wheel
pip install dist/airai-*.whl

# Verify
airai --version
airai health
```

### Step 3: Install VS Code + Cline

**On Client Workstation:**
```bash
# Install VS Code
# Download from https://code.visualstudio.com/

# Install Cline extension
# From VS Code: Extensions → Search "Cline" → Install
# Or from .vsix file for air-gap
```

**Configure Cline:**
1. Open VS Code
2. Click Cline icon in sidebar
3. Settings → API Provider: **Ollama**
4. Base URL: `http://SERVER_IP:11434`
5. Model: `qwen-32b-cline`
6. Context window: `131072`

### Step 4: Configure AirAI

```bash
# Create config file
mkdir -p ~/.airai
cat > ~/.airai/config.yaml << EOF
server:
  host: "SERVER_IP"
  port: 11434

defaults:
  model: "qwen-32b-cline"
  temperature: 0.2
  num_ctx: 131072
EOF
```

## Usage Workflows

### Workflow 1: Quick Terminal Tasks

Use AirAI for fast, command-line operations:

```bash
# Check system health
airai health

# Quick code generation
airai chat qwen-32b-cline "Write a Python decorator for timing functions"

# Fast code review
airai code review src/new_module.py

# List and manage models
airai models list
```

### Workflow 2: Interactive Development

Use Cline in VS Code for:

- Complex multi-file changes
- Iterative refinement
- Visual code review
- Debugging assistance
- Learning and exploration

**Example Session:**
1. Open VS Code with your project
2. Click Cline in sidebar
3. Chat: "Refactor this API to use async/await"
4. Review proposed changes visually
5. Accept or modify suggestions
6. Iterate until perfect

### Workflow 3: Hybrid Approach

Combine both for maximum efficiency:

**Morning Routine:**
```bash
# AirAI: Check server status
airai health

# AirAI: Quick model updates
airai models list

# VS Code: Open project and start coding
code .
```

**During Development:**
- **Quick queries**: Use AirAI in terminal
- **Complex changes**: Use Cline in VS Code
- **Code review**: Use AirAI for automated reviews
- **Refactoring**: Use Cline for interactive refinement

**Example Project Workflow:**
```bash
# 1. AirAI: Quick file edit
airai code edit utils.py "add type hints"

# 2. Cline: Complex feature development
# (Use VS Code for multi-file changes)

# 3. AirAI: Code review
airai code review src/

# 4. Cline: Fix issues found
# (Use VS Code for interactive fixes)

# 5. AirAI: Generate tests
airai code test src/new_feature.py
```

## Task Assignment Guide

### Use AirAI When:

✅ **Server Management**
```bash
airai health
airai models list
airai server status
```

✅ **Quick Queries**
```bash
airai ask qwen-32b-cline "How do I use asyncio?"
airai chat qwen-32b-cline "Write a regex for emails"
```

✅ **Batch Operations**
```bash
# Review all files
airai code review src/

# Generate tests for multiple files
for file in src/*.py; do
  airai code test "$file"
done
```

✅ **Automation & Scripts**
```bash
# In git hooks, CI/CD, makefiles
airai code review src/ > review.txt
```

✅ **Container Operations**
```bash
airai container build
airai container run
airai container export
```

### Use Cline When:

✅ **Interactive Development**
- Exploring design alternatives
- Learning new concepts
- Iterative refinement
- Back-and-forth conversation

✅ **Visual Editing**
- Multi-file changes
- Reviewing diffs visually
- Complex refactoring
- Structural changes

✅ **IDE Integration**
- Using with debugger
- Integrated terminal
- File navigation
- Git integration

✅ **Long Conversations**
- Project planning
- Architecture discussions
- Detailed explanations
- Troubleshooting

## Advanced Integration

### Shared Configuration

Both tools use the same Ollama server:

```yaml
# ~/.airai/config.yaml (AirAI)
server:
  host: "192.168.1.100"
  port: 11434

# VS Code settings.json (Cline)
{
  "cline.apiProvider": "ollama",
  "cline.ollamaBaseUrl": "http://192.168.1.100:11434",
  "cline.model": "qwen-32b-cline"
}
```

### Custom Scripts

Combine AirAI with shell scripts:

```bash
#!/bin/bash
# review-and-fix.sh

echo "Running code review..."
airai code review src/ > review.txt

echo "Found issues. Opening in VS Code..."
code review.txt

echo "Use Cline to fix issues interactively"
```

### Git Hooks

```bash
# .git/hooks/pre-commit

#!/bin/bash
echo "Running AI code review..."
airai code review --exit-code $(git diff --cached --name-only)

if [ $? -ne 0 ]; then
    echo "Code review found issues. Fix them or use git commit --no-verify"
    exit 1
fi
```

## Performance Tips

### Model Selection

**For AirAI (Quick Tasks):**
```bash
# Use lightweight model
airai chat qwen-14b-cline "quick question"
```

**For Cline (Complex Tasks):**
- Use `qwen-32b-cline` for coding
- Use `deepseek-r1-32b-cline` for reasoning
- Set in Cline settings

### Caching Strategies

Run frequently-used models on server:
```bash
# Pre-load models
airai models pull qwen-32b-cline
airai models pull deepseek-r1-32b-cline
```

### Network Optimization

For best performance:
- Use wired Gigabit connection
- Keep server and clients on same VLAN
- Monitor with `airai health --watch`

## Troubleshooting

### Cline Can't Connect

1. **Check server health:**
```bash
airai health
```

2. **Test API directly:**
```bash
curl http://SERVER_IP:11434/api/tags
```

3. **Verify Cline settings:**
- Correct Base URL
- Correct model name
- Firewall allows port 11434

### Slow Responses

1. **Check GPU usage:**
```bash
airai health gpu
nvidia-smi
```

2. **Monitor server:**
```bash
airai health --watch
```

3. **Reduce concurrent requests:**
- Don't run AirAI and Cline simultaneously for heavy tasks
- Adjust `OLLAMA_NUM_PARALLEL` in server config

### Different Results

AirAI and Cline may give different responses because:
- Different temperature settings
- Different context windows
- Different system prompts

**Normalize settings:**
```yaml
# AirAI config
defaults:
  temperature: 0.2
  num_ctx: 131072

# Cline settings
# Set same temperature in VS Code settings
```

## Best Practices

### 1. Division of Labor

**AirAI**: Infrastructure, batch ops, automation  
**Cline**: Interactive coding, learning, complex edits

### 2. Consistency

Use same models and settings across both tools.

### 3. Documentation

Document which tool to use for team workflows:
```markdown
## Development Workflow

1. Code review: `airai code review src/`
2. Interactive fixes: Use Cline in VS Code
3. Generate tests: `airai code test file.py`
4. Final review: Cline conversation
```

### 4. Automation

Automate repetitive tasks with AirAI:
```bash
# Daily code review
airai code review src/ >> daily-review-$(date +%Y%m%d).txt
```

### 5. Learning

Use Cline for learning, AirAI for execution:
- Learn with Cline's explanations
- Execute with AirAI's commands

## Example Scenarios

### Scenario 1: New Feature Development

```bash
# 1. AirAI: Quick architecture query
airai ask deepseek-r1-32b-cline "Best pattern for async queue processing?"

# 2. Cline: Interactive implementation
# Open VS Code, use Cline to build feature with conversation

# 3. AirAI: Generate tests
airai code test src/queue_processor.py

# 4. Cline: Review and refine tests
# Open generated tests in VS Code, refine with Cline

# 5. AirAI: Final review
airai code review src/
```

### Scenario 2: Bug Fixing

```bash
# 1. AirAI: Quick diagnosis
airai code review buggy_file.py

# 2. Cline: Interactive debugging
# Use VS Code + Cline to explore and fix

# 3. AirAI: Verify fix
airai code fix buggy_file.py
```

### Scenario 3: Code Refactoring

```bash
# 1. Cline: Plan refactoring
# Chat in VS Code about best approach

# 2. AirAI: Batch process files
for file in src/old_*.py; do
  airai code edit "$file" "modernize to Python 3.11 syntax"
done

# 3. Cline: Review and polish
# Visual review of all changes in VS Code
```

## Migration Path

### From Cline-Only

1. Install AirAI CLI
2. Use AirAI for quick terminal tasks
3. Keep Cline for complex work
4. Gradually adopt hybrid workflow

### From Scripts-Only

1. Install Cline in VS Code
2. Keep scripts for automation
3. Use Cline for interactive work
4. Best of both worlds

## Summary

**Perfect Combination:**
- **AirAI**: Fast, scriptable, infrastructure
- **Cline**: Interactive, visual, comprehensive

**When to Use What:**
- Quick task? → AirAI
- Complex change? → Cline
- Automation? → AirAI
- Learning? → Cline
- Batch operations? → AirAI
- Interactive refinement? → Cline

**Result:**
Maximum productivity with air-gapped AI assistance!

---

**See Also:**
- [AirAI CLI Documentation](../src/airai/README.md)
- [Container Deployment](CONTAINER-DEPLOYMENT.md)
- [Quickstart Guide](QUICKSTART.md)
- [CLI Usage Guide](CLI-USAGE.md)

**Version:** 1.1.0  
**Author:** Fuzemobi, LLC - Chad Rosenbohm  
**License:** MIT
