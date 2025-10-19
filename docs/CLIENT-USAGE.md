# AirGapAICoder - Client Usage Guide

**Version:** 1.0.0
**Author:** Fuzemobi, LLC - Chad Rosenbohm

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Installation](#installation)
5. [Configuration](#configuration)
6. [Using Cline](#using-cline)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Overview

This guide explains how to set up and use AirGapAICoder from client workstations. Once the server is deployed, clients can connect via VS Code with the Cline extension to access AI-assisted coding capabilities.

**What You'll Get:**
- AI-powered code generation and completion
- Intelligent refactoring suggestions
- Bug fixing assistance
- Code explanation and documentation
- Multi-language support

## Prerequisites

### Client Workstation Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Windows 10/11, macOS 10.15+, Ubuntu 20.04+ |
| **RAM** | 8GB minimum, 16GB recommended |
| **Storage** | 10GB free space |
| **Network** | Connected to same local network as server |
| **Software** | None (will be installed) |

### Server Information Needed

Before starting, obtain from your system administrator:
- Server IP address (e.g., `192.168.1.100`)
- Server port (default: `11434`)
- Available models list

## Quick Start

**5-Minute Setup:**

1. Download VS Code from: https://code.visualstudio.com/
2. Install Cline extension (provided by admin or from package)
3. Configure Cline with server address
4. Start coding with AI assistance!

## Installation

### Automated Installation (Recommended)

If your administrator provided installation scripts:

**Windows:**
```powershell
# Navigate to client files directory
cd path\to\client-files

# Run installation script
.\install-client-windows.ps1

# Enter server IP when prompted
# Example: 192.168.1.100
```

**macOS/Linux:**
```bash
# Navigate to client files directory
cd path/to/client-files

# Make script executable
chmod +x install-client-unix.sh

# Run installation
./install-client-unix.sh

# Enter server IP when prompted
```

### Manual Installation

#### Step 1: Install VS Code

**Windows:**
1. Download VS Code from: https://code.visualstudio.com/download
2. Run installer (VSCodeSetup.exe)
3. Accept defaults and complete installation

**macOS:**
1. Download VS Code for Mac
2. Open .dmg file
3. Drag Visual Studio Code to Applications folder

**Linux (Ubuntu):**
```bash
# Download and install
sudo snap install code --classic

# Or use apt
sudo apt update
sudo apt install code
```

#### Step 2: Install Cline Extension

**Option A: From File (Air-Gap)**

If you have the cline.vsix file:

1. Open VS Code
2. Press `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (macOS)
3. Click the "..." menu in Extensions panel
4. Select "Install from VSIX..."
5. Navigate to cline.vsix file
6. Click "Install"

**Option B: From Marketplace (If Connected)**

1. Open VS Code
2. Press `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (macOS)
3. Search for "Cline" or "Claude Dev"
4. Click "Install"

## Configuration

### Configure Cline for AirGapAICoder

**Method 1: Automatic (Using Config File)**

If provided a settings file:

1. Open VS Code
2. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
3. Type "Preferences: Open User Settings (JSON)"
4. Merge provided settings into your config

**Method 2: Manual Configuration**

1. **Open Cline**:
   - Click Cline icon in sidebar
   - Or press `Ctrl+Shift+P` and select "Cline: Open"

2. **Open Settings**:
   - Click gear icon (⚙️) in Cline panel

3. **Configure API Provider**:
   ```
   API Provider: Ollama
   Base URL: http://SERVER_IP:11434
   Model ID: qwen-32b-cline
   ```

   Replace `SERVER_IP` with your server's IP (e.g., `192.168.1.100`)

4. **Advanced Settings** (Optional):
   ```
   Context Window: 131072
   Max Tokens: 8192
   Temperature: 0.2
   ```

5. **Save Configuration**

### Available Models

Ask your administrator which models are available. Common options:

| Model | Best For | Speed | Quality |
|-------|----------|-------|---------|
| `qwen-32b-cline` | General coding | Medium | Excellent |
| `deepseek-r1-32b-cline` | Complex algorithms | Medium | Excellent |
| `qwen-14b-cline` | Quick responses | Fast | Good |

**Switching Models:**

1. Open Cline settings
2. Change "Model ID" to desired model
3. Save and restart Cline

## Using Cline

### Basic Usage

**Start a Conversation:**

1. Open VS Code
2. Click Cline icon in sidebar
3. Type your request in the chat box
4. Press Enter

**Example Requests:**
```
Create a Python FastAPI application with user authentication

Refactor this function to use async/await

Explain what this code does

Add error handling to the database connection

Write unit tests for the UserService class
```

### Working with Code

**Code Generation:**
```
Create a React component for a user profile card with:
- Avatar image
- Name and email
- Edit and delete buttons
```

**Refactoring:**
1. Select code in editor
2. Open Cline
3. Type: "Refactor this code to improve readability"

**Bug Fixing:**
1. Copy error message
2. Paste in Cline: "Fix this error: [error message]"
3. Provide context if needed

**Code Explanation:**
1. Select code
2. Ask: "Explain what this code does"
3. Or: "How does this algorithm work?"

### Advanced Features

**Context Awareness:**

Cline can access:
- Current file content
- Workspace file structure
- Selected code snippets
- Conversation history

**Multi-File Operations:**

```
Update the User model and create corresponding API endpoints in:
- models/user.py
- routes/users.py
- tests/test_users.py
```

**Code Review:**

```
Review this code for:
- Security vulnerabilities
- Performance issues
- Best practices
- Potential bugs
```

## Best Practices

### Writing Effective Prompts

**Be Specific:**
```
✗ "Make this better"
✓ "Refactor this function to use early returns and reduce nesting"
```

**Provide Context:**
```
✗ "Create a form"
✓ "Create a React form component for user registration with email, password, and validation"
```

**Break Down Complex Tasks:**
```
Instead of:
  "Build a complete authentication system"

Try:
  1. "Create a User model with password hashing"
  2. "Implement login/logout endpoints"
  3. "Add JWT token generation"
  4. "Create middleware for route protection"
```

### Performance Tips

**Optimize Context:**
- Close unnecessary files
- Select relevant code before asking
- Clear old conversations if context gets too large

**Model Selection:**
- Use `qwen-14b-cline` for quick queries
- Use `qwen-32b-cline` for complex refactoring
- Use `deepseek-r1-32b-cline` for algorithmic problems

**Network Considerations:**
- Larger requests take longer
- Be patient with complex code generation
- Consider breaking large tasks into smaller pieces

### Security Practices

**Code Review:**
- Always review AI-generated code
- Verify security-sensitive operations
- Test thoroughly before deploying

**Sensitive Data:**
- Don't include API keys or passwords in prompts
- Sanitize logs and examples
- Be aware of what context is shared

**Access Control:**
- Only use trusted servers
- Verify server IP before connecting
- Report suspicious behavior to admin

## Troubleshooting

### Cannot Connect to Server

**Check Network Connectivity:**
```powershell
# Windows/PowerShell
Test-Connection -ComputerName SERVER_IP -Count 4

# macOS/Linux
ping -c 4 SERVER_IP
```

**Verify Server is Running:**
```powershell
# Test API endpoint
Invoke-RestMethod -Uri "http://SERVER_IP:11434/api/tags"

# Or use curl
curl http://SERVER_IP:11434/api/tags
```

**Check Cline Configuration:**
1. Open Cline settings
2. Verify Base URL: `http://SERVER_IP:11434`
3. Check Model ID is correct
4. Save and restart VS Code

### Cline Not Responding

**Restart VS Code:**
- Close and reopen VS Code
- Reload window: `Ctrl+Shift+P` → "Developer: Reload Window"

**Check Extension:**
- Ensure Cline is enabled
- Update to latest version if available
- Reinstall extension if needed

**Clear Cache:**
```
Ctrl+Shift+P → "Developer: Clear Extension Host Cache"
```

### Slow Responses

**Check Server Load:**
- Ask administrator about server capacity
- Multiple users may slow responses
- Consider using smaller model during peak times

**Optimize Requests:**
- Reduce context size
- Break large tasks into smaller pieces
- Close unnecessary files

**Network Issues:**
- Check network latency
- Verify stable connection
- Contact network administrator

### Incorrect or Poor Quality Responses

**Improve Prompts:**
- Be more specific
- Provide more context
- Show examples of desired output

**Try Different Model:**
- Switch to `deepseek-r1-32b-cline` for reasoning
- Try `qwen-32b-cline` for general coding

**Report Issues:**
- Save problematic conversation
- Report to administrator
- Include context and expected behavior

## Getting Help

### Resources

- **Server Administrator**: For connectivity and server issues
- **Documentation**: Review [SERVER-SETUP.md](SERVER-SETUP.md) for server details
- **CLI Reference**: See `scripts/cli/README-CLI.md` for remote management
- **GitHub Issues**: https://github.com/fuzemobi/AirGapAICoder/issues

### Common Questions

**Q: Can I use multiple models simultaneously?**
A: No, select one model at a time in Cline settings.

**Q: How much does this cost?**
A: Free! Everything runs locally on your organization's server.

**Q: Can I access from home/remote?**
A: Only if connected to the same network. Check with your administrator about VPN access.

**Q: Is my code sent to the internet?**
A: No, all processing happens locally on the air-gapped server.

**Q: How do I report bugs or request features?**
A: Contact your system administrator or open a GitHub issue.

## Next Steps

- **Explore**: Try different types of coding tasks
- **Experiment**: Test various models to find your preference
- **Provide Feedback**: Help improve the system by reporting issues
- **Share**: Show colleagues how to use AirGapAICoder

## Tips for Success

1. **Start Simple**: Begin with small tasks to learn the system
2. **Iterate**: Refine AI responses with follow-up questions
3. **Review Code**: Always verify AI-generated code
4. **Ask Questions**: Use Cline to understand complex code
5. **Be Patient**: Complex tasks take time to process

---

**Happy Coding with AirGapAICoder!**

---

**Document Version:** 1.0.0
**Last Updated:** 2025-10-19
**Author:** Fuzemobi, LLC - Chad Rosenbohm
