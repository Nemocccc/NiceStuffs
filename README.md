# Offline AI Coding Tools Deployment Pack（Windows Offline Installation）

Windows Only (At least for now)

> 用于内网环境的 AI 编程工具离线部署方案。所有工具均支持断网安装。

## 目录

- [前置要求](#前置要求)
- [全流程概览](#全流程概览)
- [Claude Code CLI](#claude-code-cli)
- [Codex CLI](#codex-cli)
- [Codex Desktop](#codex-desktop)
- [附录](#附录)

---

## 前置要求

| 项目 | 要求 |
|------|------|
| 架构 | Windows 10/11 64 位（x64） |
| 权限 | 安装时需要管理员权限 |
| 联网机 | 首次准备需要一台能访问 GitHub / npm / Node.js 官网的机器 |
| 存储 | 每个工具约 350~450 MB 磁盘空间 |

---

## 全流程概览

所有三个工具遵循同一套流程：

```text
第 1 步: 联网机下载材料     →  scripts\pack-online.bat
第 2 步: 拷贝到内网机器     →  USB / 内部共享
第 3 步: 内网一键安装       →  setup.bat（右键管理员）
第 4 步: 配置内网 API       →  settings.ini 或环境变量
```

---

## Claude Code CLI

> Anthropic 官方的终端 AI 编程助手。原生 Windows 二进制，不依赖 Node 运行时。

### 全流程

**第 1 步 — 联网机下载**

```cmd
cd cc-offline
scripts\pack-online.bat
```

自动下载到本地目录：

| 下载项 | 位置 | 大小 |
|--------|------|------|
| nvm-windows | `nvm\` | 16 MB |
| Node.js 26.4.0 + npm | `node\` | 115 MB |
| claude.exe 原生二进制 | `claude-code-offline\` | 225 MB |
| **总计** | | **~355 MB** |

**第 2 步 — 拷贝到内网**

将整个 `cc-offline\` 目录复制到内网机器的任意位置（如 `D:\tools\cc-offline\`）。

**第 3 步 — 内网安装**

```cmd
# 右键 → 以管理员身份运行
setup.bat
```

**第 4 步 - 配置-可选1**

复制repo根目录下面的settings.json，放到 `~/<usr>/.claude/` 下。

**第 4 步 - 配置-可选2**

使用 cc-switch 进行代理配置，此处不对cc-switch的使用赘述
但***NOTICE***： 可选1和可选2不能同时配置，或者说，可选1的 "hasCompletedOnboarding": true 和可选2的 `跳过首次登陆` 不能同时存在。 

安装内容：

| 组件 | 安装到 |
|------|--------|
| nvm-windows | `%USERPROFILE%\.nvm\` |
| Node.js + npm | `%USERPROFILE%\.nvm\nodejs\` |
| claude.exe | `%USERPROFILE%\claude-code\bin\claude.exe` |
| 命令行入口 | `%USERPROFILE%\.nvm\claude.cmd` |
| 环境变量 | PATH 追加 nvm 目录，设置 `ANTHROPIC_BASE_URL` |

安装完成后关掉终端重开。验证：

```cmd
claude --version
```

---

## Codex CLI

> OpenAI 官方的终端 AI 编码代理。JS 包装器 + 原生 Rust 二进制。

### 全流程

**第 1 步 — 联网机下载**

```cmd
cd codex-offline
scripts\pack-online.bat
```

| 下载项 | 位置 | 大小 |
|--------|------|------|
| nvm-windows | `nvm\` | 16 MB |
| Node.js 26.4.0 + npm | `node\` | 115 MB |
| codex.js + codex.exe(308MB) | `codex-offline\` | 322 MB |
| **总计** | | **~452 MB** |

**第 2 步 — 拷贝到内网**

将整个 `codex-offline\` 目录复制到内网机器。

**第 3 步 — 内网安装**

```cmd
# 右键 → 以管理员身份运行
setup.bat
```

**第 4 步 - 配置**

使用 cc-switch 进行代理配置，此处不对cc-switch的使用赘述

安装内容：

| 组件 | 安装到 |
|------|--------|
| nvm-windows | `%USERPROFILE%\.nvm\` |
| Node.js + npm | `%USERPROFILE%\.nvm\nodejs\` |
| codex.js + native binary | `%USERPROFILE%\codex\` |
| 命令行入口 | `%USERPROFILE%\.nvm\codex.cmd` |
| 环境变量 | PATH 追加 nvm 目录，设置 `OPENAI_BASE_URL` |

验证：

```cmd
codex --version
```

---

## Codex Desktop

> OpenAI 官方的桌面 IDE，基于 Electron/Chromium。通过微软商店分发。

### 全流程

**第 1 步 — 联网机下载**

```cmd
cd codex-desktop-offline
scripts\pack-online.bat
```

| 下载项 | 位置 | 大小 |
|--------|------|------|
| 微软商店安装器(stub) | `pkg\CodexDesktopInstaller.exe` | 1.3 MB |

> 下载器 stub（1.3MB），首次运行需要从微软 CDN 拉取完整应用。

**第 2 步 — 拷贝到内网**

将 `codex-desktop-offline\` 目录复制到内网机器。

**第 3 步 — 获取纯离线 MSIX**

如果内网完全断网，需要提前在有网机器上提取完整安装包：

```cmd
# 在有 Codex Desktop 已安装的机器上运行（管理员）
scripts\extract-msix.bat
```

该脚本会自动从 `C:\Program Files\WindowsApps\` 找到 Codex Desktop 的安装目录，完整复制到 `pkg\AppxPackage\`。将这个目录拷回内网后，`setup.bat` 会自动走离线安装路径（无需联网）。

**第 3 步 — 安装**

```cmd
# 右键 → 以管理员身份运行
setup.bat
```

`setup.bat` 会按以下优先级尝试：

| 优先级 | 安装方式                           | 要求                         |
| ------ | ---------------------------------- | ---------------------------- |
| ①      | `Add-AppxPackage -Register`        | 已有 `pkg\AppxPackage\` 目录 |
| ②      | `Add-AppxPackage -Path`            | 已有 `pkg\*.msix` 文件       |
| ③      | `Add-AppxProvisionedPackage`       | 已有 `pkg\AppxPackage\` 目录 |
| ④      | `DISM /Add-ProvisionedAppxPackage` | 已有 `pkg\AppxPackage\` 目录 |
| ⑤      | 运行安装器 stub                    | 需首次联网                   |

---

## 附录

### 目录说明

```
pack/
├── cc-offline/                  Claude Code CLI 包
│   ├── settings.ini             版本与 API 配置
│   ├── settings.json            Claude Code 预配置（放入 ~/.claude/）
│   ├── setup.bat                内网安装脚本（管理员运行）
│   └── scripts/
│       ├── pack-online.bat      联网机下载脚本
│       └── verify.bat           安装后验证
│
├── codex-offline/               Codex CLI 包
│   ├── settings.ini
│   ├── settings.json
│   ├── setup.bat
│   └── scripts/
│       ├── pack-online.bat
│       └── verify.bat
│
└── codex-desktop-offline/       Codex Desktop 包
    ├── settings.ini
    ├── setup.bat
    └── scripts/
        ├── pack-online.bat
        ├── extract-msix.bat     从已装机提取离线包
        └── verify.bat
```

### 常见问题

**Q：setup.bat 提示需要管理员权限？**
A：右键 setup.bat → 以管理员身份运行。

**Q：pack-online.bat 下载失败？**
A：检查互联网连接。需要能访问 GitHub、nodejs.org、npmjs.org。

**Q：安装后命令行找不到 claude / codex？**
A：关闭当前终端，打开新终端。如果仍然找不到，重启 Windows。
