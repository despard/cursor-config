@echo off
setlocal

rem 创建配置目录
if not exist config mkdir config

rem 复制配置文件
xcopy /Y "%APPDATA%\Cursor\User\settings.json" config\ 2>nul
xcopy /Y "%APPDATA%\Cursor\User\keybindings.json" config\ 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\snippets" config\snippets 2>nul
xcopy /Y /E /I "%APPDATA%\Cursor\User\globalStorage" config\globalStorage 2>nul

rem 添加到 git
git add config/
git commit -m "更新配置 %date% %time%"
git push

echo 配置同步完成！

endlocal