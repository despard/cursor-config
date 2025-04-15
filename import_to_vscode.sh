#!/bin/bash

# 确定操作系统类型和路径
if [[ "$OSTYPE" == "darwin"* ]]; then
    CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
    VSCODE_CONFIG_DIR="$HOME/Library/Application Support/Code/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
else
    CURSOR_CONFIG_DIR="$APPDATA/Cursor/User"
    VSCODE_CONFIG_DIR="$APPDATA/Code/User"
fi

# 创建配置目录
mkdir -p config
mkdir -p "$VSCODE_CONFIG_DIR"

echo "正在从 Cursor 复制配置到 VSCode..."

# 复制配置文件到 VSCode
cp "$CURSOR_CONFIG_DIR/settings.json" "$VSCODE_CONFIG_DIR/" 2>/dev/null || true
cp "$CURSOR_CONFIG_DIR/keybindings.json" "$VSCODE_CONFIG_DIR/" 2>/dev/null || true
cp -r "$CURSOR_CONFIG_DIR/snippets" "$VSCODE_CONFIG_DIR/" 2>/dev/null || true

# 复制配置文件到 Git 仓库
cp "$CURSOR_CONFIG_DIR/settings.json" config/ 2>/dev/null || true
cp "$CURSOR_CONFIG_DIR/keybindings.json" config/ 2>/dev/null || true
cp -r "$CURSOR_CONFIG_DIR/snippets" config/ 2>/dev/null || true
cp -r "$CURSOR_CONFIG_DIR/globalStorage" config/ 2>/dev/null || true

# 导出 Cursor 已安装的扩展列表
if command -v cursor &> /dev/null; then
    cursor --list-extensions > config/cursor_extensions.txt
fi

# 为 VSCode 安装扩展
if [ -f "config/cursor_extensions.txt" ]; then
    echo "正在为 VSCode 安装扩展..."
    while IFS= read -r ext; do
        if command -v code &> /dev/null; then
            code --install-extension "$ext" --force
        fi
    done < config/cursor_extensions.txt
fi

# 更新 extensions.json
echo "{
    \"extensions\": [" > extensions.json
first=true
while IFS= read -r ext; do
    if [ "$first" = true ]; then
        echo "        \"$ext\"" >> extensions.json
        first=false
    else
        echo "        ,\"$ext\"" >> extensions.json
    fi
done < config/cursor_extensions.txt
echo "    ]
}" >> extensions.json

# 添加到 git
git add config/ extensions.json
git commit -m "从 Cursor 导入配置 $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "配置导入完成！"
echo "VSCode 配置目录: $VSCODE_CONFIG_DIR"
echo "Git 仓库已更新"