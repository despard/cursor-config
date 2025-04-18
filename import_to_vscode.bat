@echo off
setlocal enabledelayedexpansion

rem 创建配置目录
if not exist config mkdir config

echo 正在从 Cursor 复制配置到 VSCode...

rem 复制配置文件到 VSCode
xcopy /Y "%APPDATA%\Cursor\User\settings.json" "%APPDATA%\Code\User\" 2>nul
xcopy /Y "%APPDATA%\Cursor\User\keybindings.json" "%APPDATA%\Code\User\" 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\snippets" "%APPDATA%\Code\User\snippets" 2>nul

rem 复制主题相关的配置文件
xcopy /Y /E /I "%APPDATA%\Cursor\User\workspaceStorage" "%APPDATA%\Code\User\workspaceStorage" 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\globalStorage" "%APPDATA%\Code\User\globalStorage" 2>nul

rem 复制配置文件到 Git 仓库
xcopy /Y "%APPDATA%\Cursor\User\settings.json" config\ 2>nul
xcopy /Y "%APPDATA%\Cursor\User\keybindings.json" config\ 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\snippets" config\snippets 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\globalStorage" config\globalStorage 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\workspaceStorage" config\workspaceStorage 2>nul

rem 导出 Cursor 已安装的扩展列表
where cursor >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    cursor --list-extensions > config\cursor_extensions.txt
)

rem 创建主题扩展列表
echo dracula-theme.theme-dracula> config\theme_extensions.txt
echo GitHub.github-vscode-theme>> config\theme_extensions.txt
echo zhuangtongfa.material-theme>> config\theme_extensions.txt
echo PKief.material-icon-theme>> config\theme_extensions.txt
echo vscode-icons-team.vscode-icons>> config\theme_extensions.txt
echo equinusocio.vsc-material-theme>> config\theme_extensions.txt
echo azemoh.one-monokai>> config\theme_extensions.txt

rem 为 VSCode 安装扩展
if exist config\cursor_extensions.txt (
    echo 正在为 VSCode 安装扩展...
    for /f "tokens=*" %%i in (config\cursor_extensions.txt) do (
        where code >nul 2>nul
        if !ERRORLEVEL! EQU 0 (
            code --install-extension %%i --force
        )
    )
)

rem 安装主题扩展
if exist config\theme_extensions.txt (
    echo 正在安装主题扩展...
    for /f "tokens=*" %%i in (config\theme_extensions.txt) do (
        where code >nul 2>nul
        if !ERRORLEVEL! EQU 0 (
            code --install-extension %%i --force
        )
    )
)

rem 更新 extensions.json
echo { > extensions.json
echo     "extensions": [ >> extensions.json
set first=true

rem 添加常规扩展
for /f "tokens=*" %%i in (config\cursor_extensions.txt) do (
    if !first!==true (
        echo         "%%i" >> extensions.json
        set first=false
    ) else (
        echo         ,"%%i" >> extensions.json
    )
)

rem 添加主题扩展
for /f "tokens=*" %%i in (config\theme_extensions.txt) do (
    if !first!==true (
        echo         "%%i" >> extensions.json
        set first=false
    ) else (
        echo         ,"%%i" >> extensions.json
    )
)

echo     ] >> extensions.json
echo } >> extensions.json

rem 添加到 git
git add config\ extensions.json
git commit -m "从 Cursor 导入配置和主题 %date% %time%"
git push

echo 配置导入完成！
echo VSCode 配置目录: %APPDATA%\Code\User
echo Git 仓库已更新

endlocal