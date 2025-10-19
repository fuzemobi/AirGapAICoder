# AirGapAICoder - System Architecture

## Document Information

- **Version**: 1.0
- **Date**: 2025-10-19
- **Status**: Design Phase

## 1. Architecture Overview

AirGapAICoder is a three-tier architecture consisting of:

1. **Inference Layer**: Ollama server with GPU-accelerated LLM inference
2. **Network Layer**: HTTP API for client-server communication
3. **Client Layer**: VS Code with Cline extension for developer interaction

```
┌──────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                               │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐     │
│  │  VS Code +     │  │  VS Code +     │  │  VS Code +     │     │
│  │  Cline Ext     │  │  Cline Ext     │  │  Cline Ext     │     │
│  └────────┬───────┘  └────────┬───────┘  └────────┬───────┘     │
└───────────┼──────────────────┼──────────────────┼───────────────┘
            │                  │                  │
            └──────────────────┼──────────────────┘
                               │ HTTP API (Port 11434)
                               │ Local Network
┌──────────────────────────────┼───────────────────────────────────┐
│                        NETWORK LAYER                              │
│                               │                                   │
│  ┌────────────────────────────▼───────────────────────────────┐  │
│  │            Ollama HTTP API Server                          │  │
│  │  • Request routing & queuing                               │  │
│  │  • Session management                                      │  │
│  │  • Load balancing                                          │  │
│  └────────────────────────────┬───────────────────────────────┘  │
└───────────────────────────────┼───────────────────────────────────┘
                                │
┌───────────────────────────────▼───────────────────────────────────┐
│                      INFERENCE LAYER                              │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Model Management                                │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │ │
│  │  │ Qwen 32B     │  │ DeepSeek R1  │  │ Qwen 14B     │      │ │
│  │  │ (Coding)     │  │ (Reasoning)  │  │ (Backup)     │      │ │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │ │
│  └─────────┼──────────────────┼──────────────────┼──────────────┘ │
│            │                  │                  │                │
│  ┌─────────▼──────────────────▼──────────────────▼──────────────┐ │
│  │              GPU Acceleration Layer (CUDA)                   │ │
│  │  • Tensor operations                                         │ │
│  │  • Memory management (VRAM)                                  │ │
│  │  • Flash attention optimization                              │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                   NVIDIA GPU Hardware                         │ │
│  │  • RTX 4090 / A6000 (24GB+ VRAM)                             │ │
│  │  • CUDA Cores for parallel processing                        │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
```

## 2. Component Architecture

### 2.1 Inference Layer

#### 2.1.1 Ollama Server

**Purpose**: Core LLM inference engine with GPU acceleration

**Key Responsibilities**:
- Load and manage AI models in VRAM
- Execute inference requests with GPU acceleration
- Manage model lifecycle (load, unload, swap)
- Optimize memory usage and performance

**Technology Stack**:
- **Language**: Go (compiled binary)
- **GPU Interface**: CUDA via libraries
- **Model Format**: GGUF (quantized models)
- **API**: HTTP REST API

**Key Components**:

```
Ollama Server
├── HTTP Server (Port 11434)
│   ├── /api/generate - Streaming generation
│   ├── /api/chat - Chat completion
│   ├── /api/tags - List models
│   └── /api/show - Model details
├── Model Loader
│   ├── Model validation
│   ├── VRAM allocation
│   └── Parameter loading
├── Inference Engine
│   ├── GPU kernel execution
│   ├── Context management
│   └── Token generation
└── Memory Manager
    ├── VRAM allocation
    ├── Model caching
    └── Garbage collection
```

#### 2.1.2 GPU Acceleration

**CUDA Integration**:
- Direct GPU memory access for model weights
- Parallel tensor operations
- Optimized matrix multiplication
- Flash attention for extended context

**Memory Layout**:
```
GPU VRAM (24GB Example)
├── Model Weights (19GB) - Qwen 32B
├── KV Cache (3GB) - Context storage
├── Activation Memory (1.5GB) - Inference
└── Reserved (0.5GB) - System
```

### 2.2 Network Layer

#### 2.2.1 HTTP API Server

**Protocol**: HTTP/1.1 (optionally HTTP/2)

**Endpoints**:

| Endpoint | Method | Purpose | Parameters |
|----------|--------|---------|------------|
| `/api/generate` | POST | Generate text completion | model, prompt, options |
| `/api/chat` | POST | Chat-style interaction | model, messages, options |
| `/api/tags` | GET | List available models | - |
| `/api/show` | POST | Show model details | name |
| `/api/pull` | POST | Pull model (disabled in air-gap) | name |
| `/api/push` | POST | Push model (disabled in air-gap) | name |
| `/api/create` | POST | Create custom model | name, modelfile |
| `/api/delete` | DELETE | Delete model | name |
| `/api/copy` | POST | Copy model | source, destination |
| `/api/ps` | GET | List running models | - |

**Request Flow**:
```
Client Request
    ↓
HTTP Server (Port 11434)
    ↓
Request Validation
    ↓
Model Selection/Loading
    ↓
Queue Management
    ↓
Inference Execution
    ↓
Streaming Response
    ↓
Client Receives Tokens
```

#### 2.2.2 Session Management

**Concurrency Model**:
- Multiple concurrent requests supported
- Request queuing when GPU at capacity
- Fair scheduling (FIFO by default)
- Configurable priority levels (future)

**State Management**:
- Stateless HTTP requests
- Context maintained in KV cache
- Session isolation between users

### 2.3 Client Layer

#### 2.3.1 VS Code Integration

**Cline Extension Architecture**:

```
VS Code
├── Cline Extension
│   ├── UI Components
│   │   ├── Chat panel
│   │   ├── Inline suggestions
│   │   └── Settings panel
│   ├── API Client
│   │   ├── HTTP client (Ollama API)
│   │   ├── Request formatting
│   │   └── Response parsing
│   ├── Code Context
│   │   ├── File reading
│   │   ├── Workspace analysis
│   │   └── Syntax parsing
│   └── Action Handlers
│       ├── Code generation
│       ├── Refactoring
│       └── Explanation
└── VS Code API
    ├── Editor access
    ├── File system
    └── Terminal
```

**Communication Protocol**:
```
Cline Extension
    ↓ (HTTP POST)
{
  "model": "qwen-32b-cline",
  "prompt": "<code context>\n\nTask: ...",
  "stream": true,
  "options": {
    "temperature": 0.2,
    "num_ctx": 131072
  }
}
    ↓
Ollama Server
    ↓ (Streaming HTTP Response)
{
  "model": "qwen-32b-cline",
  "created_at": "2025-10-19T...",
  "response": "Generated code...",
  "done": false
}
    ↓
Cline Extension (UI Update)
```

## 3. Data Flow Architecture

### 3.1 Code Generation Flow

```
┌──────────────┐
│  Developer   │
│  Action      │
└──────┬───────┘
       │ 1. User types request in Cline chat
       ↓
┌──────────────────────────┐
│   Cline Extension        │
│  • Gather workspace      │
│    context (files,       │
│    cursor position)      │
│  • Format prompt         │
└──────┬───────────────────┘
       │ 2. HTTP POST with prompt + context
       ↓
┌──────────────────────────┐
│   Network Layer          │
│  • Receive request       │
│  • Validate payload      │
│  • Add to queue          │
└──────┬───────────────────┘
       │ 3. Queue processes request
       ↓
┌──────────────────────────┐
│   Ollama Inference       │
│  • Load model (if needed)│
│  • Execute on GPU        │
│  • Generate tokens       │
└──────┬───────────────────┘
       │ 4. Stream response tokens
       ↓
┌──────────────────────────┐
│   Cline Extension        │
│  • Parse response        │
│  • Update UI incrementally│
│  • Apply code changes    │
└──────┬───────────────────┘
       │ 5. Display to user
       ↓
┌──────────────┐
│  Developer   │
│  Reviews     │
│  Generated   │
│  Code        │
└──────────────┘
```

### 3.2 Context Management

**Context Building**:
```
User Request
    ↓
Cline gathers context:
├── Current file content
├── Selected code snippet
├── Workspace file structure
├── Related files (imports, references)
└── Conversation history
    ↓
Format into prompt:
┌─────────────────────────────┐
│ System: You are a coding... │
│ User: <workspace context>   │
│ User: <current file>        │
│ User: <user request>        │
└─────────────────────────────┘
    ↓
Send to Ollama (within 131k token limit)
```

**Context Window Management**:
- Maximum: 131,072 tokens (~400k characters)
- Effective: ~100k tokens (reserve for generation)
- Trimming strategy: Oldest messages removed first
- Context compression: Summarize old conversations

## 4. Storage Architecture

### 4.1 Server Storage Layout

```
C:\
├── Program Files\
│   └── Ollama\
│       ├── ollama.exe           # Main executable
│       └── lib\                 # CUDA libraries
├── Users\<username>\
│   └── .ollama\
│       ├── models\              # Model storage (~50GB)
│       │   ├── manifests\       # Model metadata
│       │   ├── blobs\           # Model weights (GGUF files)
│       │   └── registry\        # Model registry
│       └── logs\                # Operation logs
└── ProgramData\
    └── Ollama\
        └── config\              # Server configuration
```

**Model Storage Format (GGUF)**:
- Quantized weights (4-bit, 5-bit, 8-bit, 16-bit)
- Metadata (architecture, parameters, tokenizer)
- Optimized for fast loading
- Compressed for storage efficiency

### 4.2 Client Storage

```
VS Code User Directory
└── globalStorage\
    └── saoudrizwan.claude-dev\
        ├── settings\
        │   └── cline_mcp_settings.json
        ├── conversations\
        │   └── <conversation-id>.json
        └── cache\
            └── workspace-context\
```

## 5. Security Architecture

### 5.1 Network Security

**Network Isolation**:
```
┌─────────────────────────────────────┐
│       Internet (Blocked)            │
└─────────────────────────────────────┘
                 ✗ No Connection
                 ↓
┌─────────────────────────────────────┐
│      Corporate Firewall             │
└─────────────────────────────────────┘
                 ✗ No Route
                 ↓
┌─────────────────────────────────────┐
│   Isolated VLAN (192.168.X.0/24)   │
│  ┌───────────┐      ┌───────────┐  │
│  │  Server   │  ↔   │ Clients   │  │
│  │  :11434   │      │ (Trusted) │  │
│  └───────────┘      └───────────┘  │
└─────────────────────────────────────┘
```

**Access Control**:
- Windows Firewall rules (inbound port 11434 only)
- IP whitelist for trusted clients (optional)
- No authentication by default (network-level security)
- Optional: Basic auth via reverse proxy (future)

### 5.2 Data Security

**Data Flow Security**:
```
Developer Code
    ↓ (Local network, unencrypted by default)
Ollama Server
    ↓ (In-memory processing, GPU VRAM)
Generated Response
    ↓ (Local network, unencrypted by default)
Developer Workstation
```

**Security Measures**:
- ✅ No data leaves local network
- ✅ No external API calls
- ✅ No telemetry or analytics
- ✅ Logs stored locally only
- ⚠️ Network traffic unencrypted (future: TLS)
- ⚠️ No authentication (future: optional)

### 5.3 Model Security

**Model Integrity**:
- SHA256 checksums for downloaded models
- Read-only model files (prevent tampering)
- Model provenance tracking (source, date)
- Isolated model directory

## 6. Performance Architecture

### 6.1 GPU Utilization

**Optimization Strategies**:
```
Model Loading
    ↓
VRAM Allocation (19GB for 32B model)
    ↓
Persistent Memory (KV cache)
    ↓
Inference Execution
├── Forward pass (GPU kernels)
├── Token sampling (GPU)
└── Context extension (flash attention)
    ↓
Memory Management
├── KV cache recycling
├── Activation memory reuse
└── Garbage collection
```

**Flash Attention**:
- Reduces memory usage for long contexts
- Enables 131k token context window
- 2-4x faster for long sequences
- Critical for large codebase analysis

### 6.2 Concurrency Model

**Request Handling**:
```
Request 1 ──┐
Request 2 ──┼─→ Queue (FIFO) ─→ GPU Processing (Sequential)
Request 3 ──┘                    │
                                 ↓
                            Response Stream 1
                            Response Stream 2
                            Response Stream 3
```

**Optimization Techniques**:
- Continuous batching (future enhancement)
- KV cache sharing for similar contexts (future)
- Speculative decoding (future)
- Quantization (4-bit, 5-bit, 8-bit)

### 6.3 Performance Metrics

**Target Performance**:

| Metric | Target | Measurement Point |
|--------|--------|-------------------|
| Time to First Token (TTFT) | < 500ms | Client request to first response |
| Tokens per Second (TPS) | > 50 tokens/s | Sustained generation speed |
| Concurrent Users | 3-5 | Without queueing delay |
| Model Load Time | < 10s | Cold start |
| Model Swap Time | < 15s | Switch between models |
| GPU Utilization | > 80% | During active inference |
| Memory Efficiency | < 90% VRAM | Peak usage |

## 7. Deployment Architecture

### 7.1 Air-Gap Deployment Process

```
┌─────────────────────────────────────────────────────────┐
│              PHASE 1: Staging (Internet)                │
├─────────────────────────────────────────────────────────┤
│  1. Download Ollama installer                           │
│  2. Install Ollama and pull models                      │
│  3. Create custom Modelfiles (extended context)         │
│  4. Download VS Code + Cline extension                  │
│  5. Download NVIDIA drivers + CUDA                      │
│  6. Package everything for transfer                     │
│                                                          │
│  Output: ollama-airgap-package.zip (~50GB)              │
└─────────────────────────────────────────────────────────┘
                          ↓ (USB Transfer)
┌─────────────────────────────────────────────────────────┐
│           PHASE 2: Target Server (Air-gap)              │
├─────────────────────────────────────────────────────────┤
│  1. Install NVIDIA drivers + CUDA                       │
│  2. Install Ollama from offline installer               │
│  3. Copy model files to %USERPROFILE%\.ollama\models   │
│  4. Configure environment variables                     │
│  5. Start Ollama server                                 │
│  6. Configure Windows Firewall                          │
│  7. Verify GPU detection and model loading              │
└─────────────────────────────────────────────────────────┘
                          ↓ (Network)
┌─────────────────────────────────────────────────────────┐
│              PHASE 3: Client Setup                      │
├─────────────────────────────────────────────────────────┤
│  1. Install VS Code on client workstations              │
│  2. Install Cline extension from .vsix                  │
│  3. Configure Cline to point to server IP:11434         │
│  4. Test connection and inference                       │
└─────────────────────────────────────────────────────────┘
```

### 7.2 Package Structure

```
ollama-airgap-package/
├── installers/
│   ├── OllamaSetup.exe
│   ├── VSCodeSetup.exe
│   ├── NVIDIA-Driver.exe
│   └── CUDA-Toolkit.exe
├── extensions/
│   └── cline-<version>.vsix
├── models/
│   ├── manifests/
│   ├── blobs/
│   └── registry/
├── config/
│   ├── modelfiles/
│   │   ├── Modelfile-qwen32b
│   │   └── Modelfile-deepseek32b
│   └── cline/
│       └── settings-template.json
├── scripts/
│   ├── install-server.ps1
│   ├── install-client.ps1
│   ├── verify-setup.ps1
│   └── start-ollama.ps1
├── docs/
│   ├── INSTALLATION.md
│   └── TROUBLESHOOTING.md
└── MANIFEST.txt
```

## 8. Monitoring & Observability

### 8.1 Monitoring Architecture

```
┌──────────────────────────────────────────┐
│         Monitoring Dashboard             │
│  (Future: Web UI or PowerShell)          │
└───────────────┬──────────────────────────┘
                │
    ┌───────────┼───────────┐
    ↓           ↓           ↓
┌────────┐  ┌────────┐  ┌─────────┐
│ Ollama │  │  GPU   │  │ Windows │
│  Logs  │  │ nvidia-│  │  Event  │
│        │  │  smi   │  │  Viewer │
└────────┘  └────────┘  └─────────┘
```

### 8.2 Key Metrics

**System Metrics**:
- GPU utilization (%)
- VRAM usage (GB)
- GPU temperature (°C)
- CPU usage (%)
- System RAM usage (GB)
- Disk I/O (MB/s)
- Network throughput (MB/s)

**Application Metrics**:
- Active models loaded
- Request queue length
- Average response time
- Tokens generated per second
- Total requests processed
- Error rate
- Concurrent connections

**Business Metrics**:
- Daily active users
- Requests per user
- Popular model usage
- Average context size
- Code generation vs. chat queries

### 8.3 Logging

**Log Types**:
```
Ollama Logs
├── INFO: Model loaded (qwen-32b-cline, 19.2GB, 4.2s)
├── INFO: Request received (client: 192.168.1.50, prompt: 247 tokens)
├── INFO: Inference started (model: qwen-32b-cline, ctx: 247)
├── INFO: Generation complete (tokens: 342, time: 6.8s, tps: 50.3)
└── ERROR: CUDA out of memory (requested: 512MB, available: 128MB)
```

**Log Locations**:
- Ollama: `%LOCALAPPDATA%\Ollama\logs\`
- Windows Events: Application log
- Custom monitoring: `C:\ProgramData\AirGapAICoder\logs\`

## 9. Scalability Considerations

### 9.1 Vertical Scaling

**GPU Upgrade Path**:
```
24GB VRAM → 32B model (primary)
    ↓ Upgrade
48GB VRAM → 72B model (better quality)
    ↓ Upgrade
80GB VRAM → 72B + multiple smaller models
```

### 9.2 Horizontal Scaling (Future)

**Multi-Server Architecture**:
```
┌─────────────┐
│ Load        │
│ Balancer    │
│ (nginx)     │
└──────┬──────┘
       │
   ┌───┴───┬───────┐
   ↓       ↓       ↓
┌──────┐ ┌──────┐ ┌──────┐
│Server│ │Server│ │Server│
│  1   │ │  2   │ │  3   │
│Qwen  │ │DeepS.│ │Qwen  │
│ 32B  │ │  32B │ │ 72B  │
└──────┘ └──────┘ └──────┘
```

## 10. Disaster Recovery

### 10.1 Backup Strategy

**Critical Components**:
```
Backup
├── Models (~50GB)
│   └── Full copy to external storage
├── Configuration
│   ├── Environment variables
│   ├── Modelfiles
│   └── Cline settings
└── Logs (optional)
    └── Last 30 days
```

### 10.2 Recovery Procedures

**Server Failure**:
1. Install fresh OS on replacement hardware
2. Install NVIDIA drivers + CUDA
3. Install Ollama from backup
4. Restore model files
5. Apply configuration
6. Verify GPU detection
7. Test inference

**Recovery Time Objective (RTO)**: < 2 hours
**Recovery Point Objective (RPO)**: 0 (no data loss, models are static)

## 11. Technology Stack Summary

| Layer | Component | Technology | Version |
|-------|-----------|------------|---------|
| **OS** | Server OS | Windows 11 Pro | Latest |
| **Inference** | LLM Server | Ollama | Latest stable |
| **Inference** | GPU Driver | NVIDIA Driver | Latest production |
| **Inference** | GPU Library | CUDA Toolkit | 12.0+ |
| **Models** | Coding | Qwen 2.5 Coder | 32B, 14B |
| **Models** | Reasoning | DeepSeek R1 | 32B |
| **Client** | IDE | VS Code | Latest stable |
| **Client** | Extension | Cline | Latest compatible |
| **Scripts** | Automation | PowerShell | 5.1+ (built-in) |
| **Network** | Protocol | HTTP/1.1 | - |
| **Storage** | Models | GGUF format | - |

## 12. Future Architecture Enhancements

### Phase 2: Enhanced Management
- Web-based admin dashboard
- REST API for monitoring
- Automated health checks
- Performance analytics

### Phase 3: Advanced Features
- Multi-GPU support
- Model hot-swapping
- Advanced caching strategies
- Fine-tuning capabilities

### Phase 4: Enterprise Features
- RBAC (Role-Based Access Control)
- TLS/SSL encryption
- Audit logging and compliance
- Integration with CI/CD pipelines

---

**Document Control**:
- **Location**: `/docs/ARCHITECTURE.md`
- **Maintained by**: Solution Architect
- **Review Frequency**: On major architectural changes
