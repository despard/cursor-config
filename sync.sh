#!/bin/bash

# 确定操作系统类型
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
    EXTENSIONS_DIR="$HOME/.cursor/extensions"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONFIG_DIR="$HOME/.config/Cursor/User"
    EXTENSIONS_DIR="$HOME/.cursor/extensions"
else
    CONFIG_DIR="$APPDATA/Cursor/User"
    EXTENSIONS_DIR="$APPDATA/cursor/extensions"
fi

# 创建配置目录
mkdir -p config

# 复制配置文件
cp "$CONFIG_DIR/settings.json" config/ 2>/dev/null || true
cp "$CONFIG_DIR/keybindings.json" config/ 2>/dev/null || true
cp -r "$CONFIG_DIR/snippets" config/ 2>/dev/null || true
cp -r "$CONFIG_DIR/globalStorage" config/ 2>/dev/null || true

# 导出已安装的扩展列表
if command -v code &> /dev/null; then
    code --list-extensions > config/installed_extensions.txt
fi

# 同步扩展
if [ -f "extensions.json" ]; then
    echo "正在同步扩展..."
    # 读取 extensions.json 并安装扩展
    extensions=$(cat extensions.json | grep -o '"[^"]*"' | grep -v "extensions" | tr -d '"')
    for ext in $extensions; do
        if command -v code &> /dev/null; then
            code --install-extension "$ext" --force
        fi
    done
fi

# 添加到 git
git add config/
git commit -m "更新配置 $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "配置同步完成！"