@echo off
setlocal enabledelayedexpansion

rem 创建配置目录
if not exist config mkdir config

rem 复制配置文件
xcopy /Y "%APPDATA%\Cursor\User\settings.json" config\ 2>nul
xcopy /Y "%APPDATA%\Cursor\User\keybindings.json" config\ 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\snippets" config\snippets 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\globalStorage" config\globalStorage 2>nul

rem 导出已安装的扩展列表
where code >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    code --list-extensions > config\installed_extensions.txt
)

rem 同步扩展
if exist extensions.json (
    echo 正在同步扩展...
    for /f "tokens=*" %%i in ('type extensions.json ^| findstr /r /c:"\".*\"" ^| findstr /v "extensions" ^| find /v "{" ^| find /v "}" ^| find /v "[" ^| find /v "]"') do (
        set ext=%%i
        set ext=!ext:"=!
        set ext=!ext:,=!
        where code >nul 2>nul
        if !ERRORLEVEL! EQU 0 (
            code --install-extension !ext! --force
        )
    )
)

rem 添加到 git
git add config/
git commit -m "更新配置 %date% %time%"
git push

echo 配置同步完成！

endlocal