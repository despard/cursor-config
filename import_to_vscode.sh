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

# 复制主题相关的配置文件
cp -r "$CURSOR_CONFIG_DIR/workspaceStorage" "$VSCODE_CONFIG_DIR/" 2>/dev/null || true
cp -r "$CURSOR_CONFIG_DIR/globalStorage" "$VSCODE_CONFIG_DIR/" 2>/dev/null || true

# 复制配置文件到 Git 仓库
cp "$CURSOR_CONFIG_DIR/settings.json" config/ 2>/dev/null || true
cp "$CURSOR_CONFIG_DIR/keybindings.json" config/ 2>/dev/null || true
cp -r "$CURSOR_CONFIG_DIR/snippets" config/ 2>/dev/null || true
cp -r "$CURSOR_CONFIG_DIR/globalStorage" config/ 2>/dev/null || true
cp -r "$CURSOR_CONFIG_DIR/workspaceStorage" config/ 2>/dev/null || true

# 导出 Cursor 已安装的扩展列表
if command -v cursor &> /dev/null; then
    cursor --list-extensions > config/cursor_extensions.txt
fi

# 提取主题相关的扩展
if [ -f "$CURSOR_CONFIG_DIR/settings.json" ]; then
    # 从 settings.json 中提取主题相关的设置
    THEME_EXTS=$(grep -o '"workbench.colorTheme":\s*"[^"]*"' "$CURSOR_CONFIG_DIR/settings.json" | grep -o '[^"]*$' || true)
    ICON_THEME=$(grep -o '"workbench.iconTheme":\s*"[^"]*"' "$CURSOR_CONFIG_DIR/settings.json" | grep -o '[^"]*$' || true)
    
    # 常见主题扩展
    echo "dracula-theme.theme-dracula" >> config/theme_extensions.txt
    echo "GitHub.github-vscode-theme" >> config/theme_extensions.txt
    echo "zhuangtongfa.material-theme" >> config/theme_extensions.txt
    echo "PKief.material-icon-theme" >> config/theme_extensions.txt
    echo "vscode-icons-team.vscode-icons" >> config/theme_extensions.txt
    echo "equinusocio.vsc-material-theme" >> config/theme_extensions.txt
    echo "azemoh.one-monokai" >> config/theme_extensions.txt
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

# 安装主题扩展
if [ -f "config/theme_extensions.txt" ]; then
    echo "正在安装主题扩展..."
    while IFS= read -r ext; do
        if command -v code &> /dev/null; then
            code --install-extension "$ext" --force
        fi
    done < config/theme_extensions.txt
fi

# 更新 extensions.json
echo "{
    \"extensions\": [" > extensions.json
first=true

# 添加常规扩展
while IFS= read -r ext; do
    if [ "$first" = true ]; then
        echo "        \"$ext\"" >> extensions.json
        first=false
    else
        echo "        ,\"$ext\"" >> extensions.json
    fi
done < config/cursor_extensions.txt

# 添加主题扩展
while IFS= read -r ext; do
    if [ "$first" = true ]; then
        echo "        \"$ext\"" >> extensions.json
        first=false
    else
        echo "        ,\"$ext\"" >> extensions.json
    fi
done < config/theme_extensions.txt

echo "    ]
}" >> extensions.json

# 添加到 git
git add config/ extensions.json
git commit -m "从 Cursor 导入配置和主题 $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "配置导入完成！"
echo "VSCode 配置目录: $VSCODE_CONFIG_DIR"
echo "Git 仓库已更新"