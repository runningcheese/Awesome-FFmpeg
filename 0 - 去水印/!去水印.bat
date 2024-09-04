@echo off

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，选择一个文件，多个文件或文件夹，拖放到此 BAT 文件图标上。
    PAUSE
    EXIT /B 1
)

REM 手动输入 delogo 参数
SET /P x="请输入水印区域的起始 x 坐标（不输入则默认 100）："
SET /P y="请输入水印区域的起始 y 坐标（不输入则默认 100）："
SET /P w="请输入水印区域的宽度 w 宽度（不输入则默认 100）："
SET /P h="请输入水印区域的高度 h 高度（不输入则默认 100）："

REM 检查用户输入是否为空，如果为空则设置默认值 100
IF "%x%"=="" SET x=100
IF "%y%"=="" SET y=100
IF "%w%"=="" SET w=100
IF "%h%"=="" SET h=100


REM 遍历所有传入的文件夹路径
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有相关文件，并依次处理
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp', '*.jpg', '*.jpeg', '*.png', '*.bmp', '*.gif';" ^
        "foreach ($file in $files) {" ^
        "$outputFile = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), [System.IO.Path]::GetFileNameWithoutExtension($file.FullName) + '_Demo.jpg');" ^
        "if ($file.Extension -in '.mp4', '.mkv', '.ts', '.wmv', '.avi', '.mpg', '.mpeg', '.mov', '.flv', '.m4v', '.rmvb', '.3gp') {" ^
        "echo 正在处理视频文件 \"$($file.FullName)\" 请勿关闭窗口...;" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'thumbnail,delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=1', '-frames:v', '1', \"`\"$outputFile`\"\" -Wait; }" ^
        "else {" ^
        "echo 正在处理图片文件 \"$($file.FullName)\" 请勿关闭窗口...;" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=1', \"`\"$outputFile`\"\" -Wait; }}"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。

REM 将 delogo 参数保存到一个新的 .bat 文件中
SET saveFile="delogo_params.bat"
(
    ECHO @echo off
    ECHO REM delogo 参数脚本
    ECHO SET x=%x%
    ECHO SET y=%y%
    ECHO SET w=%w%
    ECHO SET h=%h%

:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，选择一个文件，多个文件或文件夹，拖放到此 BAT 文件图标上。
    PAUSE
    EXIT /B 1
)

REM 遍历所有传入的文件夹路径
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有相关文件，并进行 delogo 处理
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.bmp','*.png','*.jpg', '*.jpeg', '*.gif', '*.tiff', '*.tif', '*.webp', '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$mp4File = [System.IO.Path]::ChangeExtension($file.FullName, '.mp4');" ^
        "$mp4File = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($mp4File), [System.IO.Path]::GetFileNameWithoutExtension($mp4File) + '_delogo' + [System.IO.Path]::GetExtension($mp4File));" ^
        "$mediaInfo = ffmpeg -i \"$($file.FullName)\" 2>&1 | Select-String -Pattern '\d{2,5}x\d{2,5}';" ^
        "$resolution = $mediaInfo.Matches[0].Value -split 'x';" ^
        "$width = [int]$resolution[0];" ^
        "$height = [int]$resolution[1];" ^
        "if ($width -ge $height) {" ^
            "$delogo = 'delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=0';" ^
        "} else {" ^
            "$delogo = 'delogo=x=772:y=90:w=258:h=84:show=0';" ^
        "}" ^
        "if (Test-Path \"$mp4File\") { echo MP4 文件已存在，跳过： \"$mp4File\"; Start-Sleep -Seconds 1; } else {" ^
        "echo 正在处理文件 \"$($file.FullName)\" 请勿关闭窗口...;" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', \"`\"$delogo`\"\", '-c:a', 'copy', \"`\"$mp4File`\"\" -Wait; }}"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。
EXIT /B 0

) > %saveFile%

ECHO delogo 参数已保存到 %saveFile%
EXIT /B 0
