:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，选择一个文件，多个文件或文件夹，拖放到此 BAT 文件图标上。
    PAUSE
    EXIT /B 1
)

REM 设置默认运行模式和编码方式，默认为 0 
REM 0 是 CPU，1 是 N卡， 2 是 A卡，3 是 HEVC+N卡，4 是 HEVC+A卡。
SET "gpu_codec_option=0"

REM 根据选项设置 ffmpeg 的硬件加速参数
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"


REM 设置去水印的位置和大小，默认为 100

SET x=100
SET y=100
SET w=100
SET h=100

REM 遍历所有传入的文件夹路径
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有相关文件，并依次转换为去水印的 JPG 格式
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp', '*.jpg', '*.jpeg', '*.png', '*.bmp', '*.gif';" ^
        "foreach ($file in $files) {" ^
        "$jpgFile = [System.IO.Path]::ChangeExtension($file.FullName, '.jpg');" ^
        "$jpgFile = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($jpgFile), [System.IO.Path]::GetFileNameWithoutExtension($jpgFile) + '_Delogo' + [System.IO.Path]::GetExtension($jpgFile));" ^
        "if (Test-Path \"$jpgFile\") { echo JPG 文件已存在，跳过： \"$jpgFile\"; Start-Sleep -Seconds 1; } else {" ^
        "echo 正在去水印并处理文件 \"$($file.FullName)\" 请勿关闭窗口...;" ^
        "if ('%ffmpeg_hardware%' -ne '') {" ^
            "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=0', '%ffmpeg_hardware%', '-c:a', 'copy', '-frames:v', '1', '-update', '1', \"`\"$jpgFile`\"\" -Wait;" ^
        "} else {" ^
            "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=0', '-c:a', 'copy', '-frames:v', '1', '-update', '1', \"`\"$jpgFile`\"\" -Wait;" ^
        "}}}"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。
EXIT /B 0




