# AirGapAICoder - CLI Usage Guide

**Version:** 1.0.0
**Author:** Fuzemobi, LLC - Chad Rosenbohm

## Overview

AirGapAICoder can be used from **any terminal on any platform** without requiring VS Code or any specific IDE. The CLI interface provides direct access to the Ollama API for AI-assisted coding tasks.

**Supported Platforms:**
- Windows (PowerShell, CMD, WSL)
- macOS (Terminal, iTerm2, etc.)
- Linux (any terminal emulator)
- SSH sessions
- Remote terminals
- Container environments

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [Basic Commands](#basic-commands)
4. [Code Generation](#code-generation)
5. [Advanced Usage](#advanced-usage)
6. [Integration Examples](#integration-examples)
7. [API Access](#api-access)
8. [Best Practices](#best-practices)

## Quick Start

### From Any Terminal

**Using the CLI wrapper:**
```bash
# Check server status
./scripts/cli/ollama-cli.sh status SERVER_IP:11434

# List available models
./scripts/cli/ollama-cli.sh models SERVER_IP:11434

# Generate code
./scripts/cli/ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline "Write a Python function to calculate prime numbers"
```

**Using curl directly:**
```bash
# Check server health
curl http://SERVER_IP:11434/api/tags

# Generate code
curl http://SERVER_IP:11434/api/generate -d '{
  "model": "qwen-32b-cline",
  "prompt": "Write a Python function to calculate prime numbers",
  "stream": false
}'
```

**Using PowerShell:**
```powershell
# Check server health
Invoke-RestMethod -Uri "http://SERVER_IP:11434/api/tags"

# Generate code
$body = @{
    model = "qwen-32b-cline"
    prompt = "Write a Python function to calculate prime numbers"
    stream = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://SERVER_IP:11434/api/generate" -Method POST -Body $body -ContentType "application/json"
```

## Installation

### CLI Wrapper Setup

**Unix (macOS/Linux/WSL):**
```bash
# Add to PATH
export PATH="$PATH:/path/to/AirGapAICoder/scripts/cli"

# Or create symlink
sudo ln -s /path/to/AirGapAICoder/scripts/cli/ollama-cli.sh /usr/local/bin/airgap

# Set default server
export AIRGAP_SERVER="192.168.1.100:11434"

# Test
airgap status
```

**Windows (PowerShell):**
```powershell
# Add to PATH
$env:Path += ";C:\path\to\AirGapAICoder\scripts\cli"

# Or create alias
Set-Alias -Name airgap -Value "C:\path\to\AirGapAICoder\scripts\cli\ollama-cli.ps1"

# Set default server
$env:AIRGAP_SERVER = "192.168.1.100:11434"

# Test
airgap status
```

### No Installation Required

You can also use the HTTP API directly with any HTTP client:
- `curl`
- `wget`
- `httpie`
- PowerShell's `Invoke-RestMethod`
- Python's `requests`
- Node.js `fetch` or `axios`
- Any programming language with HTTP support

## Basic Commands

### Server Status

```bash
# Using CLI wrapper
./ollama-cli.sh status SERVER_IP:11434

# Using curl
curl http://SERVER_IP:11434/api/tags

# Using PowerShell
Invoke-RestMethod http://SERVER_IP:11434/api/tags
```

### List Available Models

```bash
# CLI wrapper
./ollama-cli.sh models SERVER_IP:11434

# curl
curl http://SERVER_IP:11434/api/tags | jq '.models[].name'

# PowerShell
(Invoke-RestMethod http://SERVER_IP:11434/api/tags).models | Select name,size
```

### Check Running Processes

```bash
# CLI wrapper
./ollama-cli.sh ps SERVER_IP:11434

# curl
curl http://SERVER_IP:11434/api/ps

# PowerShell
Invoke-RestMethod http://SERVER_IP:11434/api/ps
```

## Code Generation

### Simple Code Generation

**Bash:**
```bash
./ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline \
  "Write a Python function to read a CSV file"
```

**PowerShell:**
```powershell
.\ollama-cli.ps1 run SERVER_IP:11434 qwen-32b-cline `
  "Write a Python function to read a CSV file"
```

**curl:**
```bash
curl -X POST http://SERVER_IP:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-32b-cline",
    "prompt": "Write a Python function to read a CSV file",
    "stream": false
  }' | jq -r '.response'
```

### With Context

```bash
# Save your code to a file
cat > mycode.py << 'EOF'
def calculate_sum(numbers):
    return sum(numbers)
EOF

# Ask AI to improve it
./ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline \
  "Improve this code with error handling and type hints: $(cat mycode.py)"
```

### Piping Code

```bash
# Generate code and save to file
./ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline \
  "Write a Python FastAPI hello world" > app.py

# Review generated code
cat app.py

# Generate and execute
./ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline \
  "Write a bash script to list all Python files" | bash
```

## Advanced Usage

### Streaming Responses

**curl with streaming:**
```bash
curl -X POST http://SERVER_IP:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-32b-cline",
    "prompt": "Write a long Python class for user management",
    "stream": true
  }'
```

**PowerShell streaming:**
```powershell
$uri = "http://SERVER_IP:11434/api/generate"
$body = @{
    model = "qwen-32b-cline"
    prompt = "Write a long Python class for user management"
    stream = $true
} | ConvertTo-Json

Invoke-WebRequest -Uri $uri -Method POST -Body $body -ContentType "application/json"
```

### Multi-Turn Conversations

```bash
# Save conversation context
CONTEXT=""

# First question
RESPONSE=$(./ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline \
  "Create a Python class for a bank account")
echo "$RESPONSE"
CONTEXT="$RESPONSE"

# Follow-up question with context
./ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline \
  "Previous code: $CONTEXT. Now add a method for transferring money between accounts"
```

### Temperature Control

```bash
# Low temperature (more focused, deterministic)
curl -X POST http://SERVER_IP:11434/api/generate \
  -d '{
    "model": "qwen-32b-cline",
    "prompt": "Write a function to validate email addresses",
    "stream": false,
    "options": {"temperature": 0.1}
  }'

# Higher temperature (more creative)
curl -X POST http://SERVER_IP:11434/api/generate \
  -d '{
    "model": "qwen-32b-cline",
    "prompt": "Suggest creative variable names for a space game",
    "stream": false,
    "options": {"temperature": 0.8}
  }'
```

### Custom Context Window

```bash
curl -X POST http://SERVER_IP:11434/api/generate \
  -d '{
    "model": "qwen-32b-cline",
    "prompt": "Analyze this large codebase: [...]",
    "stream": false,
    "options": {"num_ctx": 131072}
  }'
```

## Integration Examples

### Python Script

```python
#!/usr/bin/env python3
import requests
import json

SERVER = "http://192.168.1.100:11434"

def generate_code(prompt, model="qwen-32b-cline"):
    response = requests.post(
        f"{SERVER}/api/generate",
        json={
            "model": model,
            "prompt": prompt,
            "stream": False
        }
    )
    return response.json()["response"]

# Usage
code = generate_code("Write a Python function to calculate fibonacci")
print(code)

# Save to file
with open("generated.py", "w") as f:
    f.write(code)
```

### Node.js Script

```javascript
#!/usr/bin/env node
const axios = require('axios');

const SERVER = 'http://192.168.1.100:11434';

async function generateCode(prompt, model = 'qwen-32b-cline') {
    const response = await axios.post(`${SERVER}/api/generate`, {
        model,
        prompt,
        stream: false
    });
    return response.data.response;
}

// Usage
generateCode('Write a JavaScript async function for API calls')
    .then(code => console.log(code))
    .catch(err => console.error(err));
```

### Bash Function

```bash
# Add to ~/.bashrc or ~/.zshrc

airgap_code() {
    local prompt="$1"
    local server="${AIRGAP_SERVER:-localhost:11434}"
    local model="${AIRGAP_MODEL:-qwen-32b-cline}"

    curl -s -X POST "http://$server/api/generate" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$model\",
            \"prompt\": \"$prompt\",
            \"stream\": false
        }" | jq -r '.response'
}

# Usage
airgap_code "Write a Python hello world"
```

### PowerShell Function

```powershell
# Add to $PROFILE

function Invoke-AirgapCode {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Prompt,

        [string]$Server = $env:AIRGAP_SERVER,
        [string]$Model = "qwen-32b-cline"
    )

    $body = @{
        model = $Model
        prompt = $Prompt
        stream = $false
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "http://$Server/api/generate" `
        -Method POST -Body $body -ContentType "application/json"

    return $response.response
}

# Usage
Invoke-AirgapCode -Prompt "Write a PowerShell function to list files"
```

### Vim Integration

```vim
" Add to ~/.vimrc

function! AirgapGenerate()
    let prompt = input('Prompt: ')
    let server = $AIRGAP_SERVER
    if empty(server)
        let server = 'localhost:11434'
    endif

    let cmd = 'curl -s -X POST http://' . server . '/api/generate '
    let cmd .= '-H "Content-Type: application/json" '
    let cmd .= '-d ''{"model":"qwen-32b-cline","prompt":"' . prompt . '","stream":false}'' '
    let cmd .= '| jq -r ".response"'

    let response = system(cmd)
    put =response
endfunction

command! AirgapCode call AirgapGenerate()

" Usage: :AirgapCode
```

### Emacs Integration

```elisp
;; Add to ~/.emacs or ~/.emacs.d/init.el

(defun airgap-generate (prompt)
  "Generate code using AirgapAICoder"
  (interactive "sPrompt: ")
  (let* ((server (or (getenv "AIRGAP_SERVER") "localhost:11434"))
         (url (concat "http://" server "/api/generate"))
         (json-data (json-encode
                     `((model . "qwen-32b-cline")
                       (prompt . ,prompt)
                       (stream . :false))))
         (response (shell-command-to-string
                    (format "curl -s -X POST %s -H 'Content-Type: application/json' -d '%s' | jq -r '.response'"
                            url json-data))))
    (insert response)))

;; Usage: M-x airgap-generate
```

## API Access

### HTTP API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/generate` | POST | Generate text/code |
| `/api/chat` | POST | Chat-style interaction |
| `/api/tags` | GET | List models |
| `/api/show` | POST | Show model details |
| `/api/ps` | GET | List running models |
| `/api/create` | POST | Create custom model |
| `/api/delete` | DELETE | Delete model |

### Generate Endpoint

**Request:**
```json
{
  "model": "qwen-32b-cline",
  "prompt": "Write a Python function",
  "stream": false,
  "options": {
    "temperature": 0.2,
    "num_ctx": 131072
  }
}
```

**Response:**
```json
{
  "model": "qwen-32b-cline",
  "created_at": "2025-10-19T10:00:00Z",
  "response": "def my_function():\n    pass",
  "done": true
}
```

### Chat Endpoint

**Request:**
```json
{
  "model": "qwen-32b-cline",
  "messages": [
    {"role": "user", "content": "Write a hello world in Python"},
    {"role": "assistant", "content": "print('Hello, World!')"},
    {"role": "user", "content": "Now add error handling"}
  ],
  "stream": false
}
```

## Best Practices

### Prompt Engineering for CLI

**Be Specific:**
```bash
# Vague
./ollama-cli.sh run SERVER "write code"

# Specific
./ollama-cli.sh run SERVER "Write a Python function that accepts a list of integers and returns the sum of even numbers with error handling for empty lists"
```

**Provide Context:**
```bash
# Include file content
./ollama-cli.sh run SERVER "Refactor this code: $(cat myfile.py)"

# Include error messages
./ollama-cli.sh run SERVER "Fix this error: $(cat error.log)"
```

**Structure Output:**
```bash
# Request specific format
./ollama-cli.sh run SERVER "Write a Python class for user management. Return only the code without explanation."

# Request with tests
./ollama-cli.sh run SERVER "Write a Python function to validate email and include pytest tests"
```

### Performance Tips

**Use Appropriate Models:**
- `qwen-14b-cline`: Quick queries, simple code
- `qwen-32b-cline`: General coding, refactoring
- `deepseek-r1-32b-cline`: Complex algorithms, reasoning

**Optimize Network Usage:**
```bash
# Set timeout for slow networks
curl --max-time 300 http://SERVER/api/generate ...

# Use compression
curl --compressed http://SERVER/api/generate ...
```

**Batch Operations:**
```bash
# Process multiple files
for file in *.py; do
    ./ollama-cli.sh run SERVER "Add docstrings to: $(cat $file)" > "documented_$file"
done
```

### Security Considerations

**Environment Variables:**
```bash
# Store server address securely
export AIRGAP_SERVER="192.168.1.100:11434"

# Don't hardcode in scripts
./ollama-cli.sh run $AIRGAP_SERVER "..."
```

**Input Sanitization:**
```bash
# Escape special characters when using user input
prompt=$(printf '%s' "$user_input" | jq -Rs .)
```

**Network Security:**
```bash
# Use SSH tunnel for remote access
ssh -L 11434:localhost:11434 user@remote-server

# Then connect to localhost
./ollama-cli.sh run localhost:11434 "..."
```

## Troubleshooting

### Connection Issues

```bash
# Test connectivity
ping SERVER_IP

# Test API
curl -v http://SERVER_IP:11434/api/tags

# Check firewall
# Windows
Test-NetConnection -ComputerName SERVER_IP -Port 11434

# Linux
nc -zv SERVER_IP 11434
```

### Response Issues

```bash
# Increase timeout
curl --max-time 600 http://SERVER/api/generate ...

# Check server load
./ollama-cli.sh ps SERVER

# Try smaller model
./ollama-cli.sh run SERVER qwen-14b-cline "..."
```

### JSON Parsing

```bash
# Pretty print JSON
curl http://SERVER/api/tags | jq '.'

# Extract specific field
curl http://SERVER/api/generate -d '...' | jq -r '.response'

# Handle errors
response=$(curl -s http://SERVER/api/generate -d '...')
if echo "$response" | jq -e .error; then
    echo "Error occurred"
    exit 1
fi
```

## Examples Gallery

### Code Generation

```bash
# Python class
./ollama-cli.sh run SERVER qwen-32b-cline "Create a Python class for a shopping cart with add, remove, and total methods"

# JavaScript module
./ollama-cli.sh run SERVER qwen-32b-cline "Write a Node.js Express middleware for JWT authentication"

# SQL query
./ollama-cli.sh run SERVER qwen-32b-cline "Write a SQL query to find top 10 customers by total purchases in the last year"

# Regex pattern
./ollama-cli.sh run SERVER qwen-32b-cline "Create a regex pattern to validate international phone numbers"
```

### Code Review

```bash
# Review code
./ollama-cli.sh run SERVER qwen-32b-cline "Review this code for security issues: $(cat app.py)"

# Suggest improvements
./ollama-cli.sh run SERVER qwen-32b-cline "Suggest performance improvements: $(cat slow_function.py)"
```

### Documentation

```bash
# Generate docstrings
./ollama-cli.sh run SERVER qwen-32b-cline "Add Google-style docstrings to: $(cat module.py)"

# Create README
./ollama-cli.sh run SERVER qwen-32b-cline "Generate a README.md for a project with these files: $(ls -1)"
```

### Testing

```bash
# Generate tests
./ollama-cli.sh run SERVER qwen-32b-cline "Write pytest tests for: $(cat calculator.py)"

# Create test data
./ollama-cli.sh run SERVER qwen-32b-cline "Generate 10 sample user records in JSON format for testing"
```

## Integration with Development Tools

### Git Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash
CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')

for file in $CHANGED_FILES; do
    # Auto-format with AI suggestions
    ./ollama-cli.sh run $AIRGAP_SERVER "Suggest formatting improvements: $(cat $file)"
done
```

### Make Integration

```makefile
# Makefile
AIRGAP_SERVER := 192.168.1.100:11434

.PHONY: ai-docs
ai-docs:
    @./scripts/cli/ollama-cli.sh run $(AIRGAP_SERVER) qwen-32b-cline \
        "Generate documentation for: $$(cat src/*.py)"

.PHONY: ai-tests
ai-tests:
    @./scripts/cli/ollama-cli.sh run $(AIRGAP_SERVER) qwen-32b-cline \
        "Generate pytest tests for: $$(cat src/main.py)"
```

### CI/CD Integration

```yaml
# .github/workflows/ai-review.yml
# (For systems with access to AirGap server)
name: AI Code Review
on: [pull_request]
jobs:
  review:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v2
      - name: AI Review
        run: |
          for file in $(git diff --name-only origin/main); do
            ./scripts/cli/ollama-cli.sh run $AIRGAP_SERVER qwen-32b-cline \
              "Review this code: $(cat $file)" >> review.txt
          done
      - name: Post Review
        run: cat review.txt
```

---

**Document Version:** 1.0.0
**Last Updated:** 2025-10-19
**Author:** Fuzemobi, LLC - Chad Rosenbohm

**No IDE Required - Use AirGapAICoder from any terminal!**
