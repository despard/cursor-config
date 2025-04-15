#!/bin/bash

# 确定操作系统类型
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONFIG_DIR="$HOME/.config/Cursor/User"
else
    CONFIG_DIR="$APPDATA/Cursor/User"
fi

# 创建配置目录
mkdir -p config

# 复制配置文件
cp "$CONFIG_DIR/settings.json" config/ 2>/dev/null || true
cp "$CONFIG_DIR/keybindings.json" config/ 2>/dev/null || true
cp -r "$CONFIG_DIR/snippets" config/ 2>/dev/null || true
cp -r "$CONFIG_DIR/globalStorage" config/ 2>/dev/null || true

# 添加到 git
git add config/
git commit -m "更新配置 $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "配置同步完成！"