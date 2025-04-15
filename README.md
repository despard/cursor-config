# Cursor 配置同步

这个仓库用于同步 Cursor IDE 的配置文件。

## 配置文件位置

- Mac: `~/Library/Application Support/Cursor/User/`
- Windows: `%APPDATA%\Cursor\User\`
- Linux: `~/.config/Cursor/User/`

## 使用方法

1. 克隆仓库：
```bash
git clone https://github.com/despard/cursor-config.git
```

2. 运行同步脚本：
```bash
# Mac/Linux
./sync.sh

# Windows
.\sync.bat
```

## 同步的配置文件

- settings.json：用户设置
- keybindings.json：快捷键设置
- snippets/：代码片段
- globalStorage/：全局存储