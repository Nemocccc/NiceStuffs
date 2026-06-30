# Offline AI Coding Tools Deployment Pack

> 一套脚本化的内网部署方案，用于在无互联网环境的 Windows 机器上安装 AI 编程工具。

## 目录

- [工具清单](#工具清单)
- [使用方式](#使用方式)
- [目录结构](#目录结构)
- [各工具说明](#各工具说明)

---

## 工具清单

| 工具 | 版本 | 类型 | 安装方式 |
|------|------|------|---------|
| **Claude Code CLI** | 2.1.195 | Anthropic 官方 AI 编码助手 | npm + 原生二进制 |
| **Codex CLI** | 0.142.4 | OpenAI 官方 AI 编码助手 | npm + 原生二进制 |
| **Codex Desktop** | 2026.6.25.261 | OpenAI 官方桌面 IDE | Microsoft Store / MSIX |

---

## 使用方式

### 前置条件

- Windows 10/11 64 位
- 管理员权限（安装时需要写入环境变量）
- 首次准备需要一台有互联网的机器来下载依赖

### 快速开始

**第一步：在联网机上准备材料**

```cmd
cd cc-offline
scripts\pack-online.bat
```

脚本会自动下载 nvm-windows、Node.js 和对应的 AI 工具。

**第二步：拷贝到内网**

将整个包目录复制到 U 盘，带到内网机器。

**第三步：安装**

右键 `setup.bat` → **以管理员身份运行**，等待完成。

**第四步：验证**

```cmd
node --version
npm --version
claude --version    (cc-offline)
codex --version     (codex-offline)
```

---

## 目录结构

```
pack/
├── README.md
│
├── cc-offline/                # Claude Code CLI 离线包
│   ├── settings.ini           # 版本配置
│   ├── setup.bat              # 内网安装脚本（管理员）
│   └── scripts/
│       ├── pack-online.bat    # 联网下载脚本
│       └── verify.bat         # 安装验证
│
├── codex-offline/             # Codex CLI 离线包
│   ├── settings.ini
│   ├── setup.bat
│   └── scripts/
│       ├── pack-online.bat
│       └── verify.bat
│
└── codex-desktop-offline/     # Codex Desktop 离线包
    ├── settings.ini
    ├── setup.bat
    └── scripts/
        ├── pack-online.bat
        ├── extract-msix.bat   # 从已安装机器导出 MSIX
        └── verify.bat
```

### 下载说明

运行 `pack-online.bat` 后会在各自目录下生成：

| 包 | 下载后新增的目录/文件 | 大小 |
|----|----------------------|------|
| `cc-offline/` | `nvm/`, `node/node-v26.4.0-win-x64/`, `claude-code-offline/` | ~355 MB |
| `codex-offline/` | `nvm/`, `node/node-v26.4.0-win-x64/`, `codex-offline/` | ~452 MB |
| `codex-desktop-offline/` | `pkg/CodexDesktopInstaller.exe` | ~1.3 MB |

> **注意**：Codex Desktop 的安装器是微软商店下载器 stub，首次安装需要联网。
> 如需纯离线 MSIX，在已安装 Codex Desktop 的机器上运行 `scripts\extract-msix.bat`。

---

## 各工具说明

### cc-offline — Claude Code CLI

Claude Code 是 Anthropic 官方的终端 AI 编程助手。

- **安装文件**：`claude-code-offline\node_modules\@anthropic-ai\claude-code\bin\claude.exe` (225 MB 原生二进制)
- **安装路径**：`%USERPROFILE%\claude-code\bin\claude.exe`
- **命令行入口**：`claude`（通过 `%USERPROFILE%\.nvm\claude.cmd`）
- **环境变量**：`ANTHROPIC_BASE_URL`（内网 API 地址）

### codex-offline — Codex CLI

Codex CLI 是 OpenAI 官方的终端 AI 编码代理。

- **入口文件**：`codex-offline\node_modules\@openai\codex\bin\codex.js`（JS 包装器）
- **原生二进制**：`codex-offline\...\codex-win32-x64\vendor\...\bin\codex.exe` (309 MB)
- **安装路径**：`%USERPROFILE%\codex\bin\codex.js`
- **命令行入口**：`codex`（通过 `%USERPROFILE%\.nvm\codex.cmd`）
- **环境变量**：`OPENAI_BASE_URL`（内网 API 地址）

### codex-desktop-offline — Codex Desktop

Codex Desktop 是 OpenAI 官方的桌面 IDE，基于 Electron/Chromium。

- **分发方式**：Microsoft Store（Windows 无独立 MSIX 下载链接）
- **安装文件**：`pkg/CodexDesktopInstaller.exe` (1.3 MB 下载器 stub)
- **纯离线安装**：详见下方"提取 MSIX"部分

#### 提取 MSIX（纯离线部署）

Codex Desktop 在 Windows 上仅通过 Microsoft Store 分发。要获得纯离线安装包：

1. 在有互联网的机器上从 Microsoft Store 安装 Codex Desktop
2. 将本项目复制到该机器
3. 以管理员身份运行 `scripts\extract-msix.bat`
4. 脚本会从 `C:\Program Files\WindowsApps\` 提取完整应用到 `pkg\AppxPackage\`
5. 将 `pkg\AppxPackage\` 复制到内网机器的对应位置
6. `setup.bat` 会自动检测并执行离线安装

---

## 安装细节

`setup.bat` 完成以下操作：

1. **nvm-windows**：部署到 `%USERPROFILE%\.nvm\`
2. **Node.js + npm**：注册到 `%USERPROFILE%\.nvm\nodejs\`
3. **AI 工具**：复制到 `%USERPROFILE%\claude-code\` 或 `%USERPROFILE%\codex\`
4. **命令行入口**：创建 `%USERPROFILE%\.nvm\claude.cmd` 或 `codex.cmd`
5. **环境变量**：追加 `PATH`，设置 `ANTHROPIC_BASE_URL` 或 `OPENAI_BASE_URL`

---

## 常见问题

**Q: setup.bat 提示需要管理员权限？**
A: 右键 setup.bat → 以管理员身份运行。

**Q: pack-online.bat 下载失败？**
A: 检查互联网连接，或使用代理/VPN。保证能访问 GitHub、nodejs.org、npmjs.org。

**Q: 安装后命令行找不到 claude/codex？**
A: 关闭当前终端，打开新终端。如果仍然找不到，重启 Windows。

**Q: 内网 API 地址怎么配置？**
A: 安装后手动设置环境变量：
```cmd
set ANTHROPIC_BASE_URL=http://your-internal-api:8080
set ANTHROPIC_API_KEY=***
```# --- 或 ---
set OPENAI_BASE_URL=http://your-internal-api:8080
set OPENAI_API_KEY=***
```## License

各工具本身遵循其原作者的许可证：
- **Claude Code CLI** © Anthropic
- **Codex CLI / Codex Desktop** © OpenAI
- 本仓库脚本基于 MIT 许可证
