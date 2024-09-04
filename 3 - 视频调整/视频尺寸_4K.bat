:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，选择一个文件，多个文件或文件夹，拖放到此 BAT 文件图标上。
    PAUSE
    EXIT /B 1
)

REM 定义允许的文件扩展名
set "valid_exts=.mp4 .mkv .ts .wmv .avi .mpg .mpeg .mov .flv .m4v .rmvb .3gp"

REM 设置默认运行模式和编码方式，默认为 0 
REM 0 是 CPU，1 是 N卡， 2 是 A卡，3 是 HEVC+N卡，4 是 HEVC+A卡。
SET "gpu_codec_option=0"

REM 根据选项设置 ffmpeg 的硬件加速参数
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

REM 检查文件扩展名是否在允许的范围内
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO 奶酪提示你：当前文件格式不支持，请选择“视频”文件。
        PAUSE
        EXIT /B 1
    )

REM 遍历所有传入的文件夹路径
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有相关文件，并依次转换为 4K MP4 格式
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$mp4File = [System.IO.Path]::ChangeExtension($file.FullName, '.mp4');" ^
        "$newFileName = [System.IO.Path]::GetFileNameWithoutExtension($mp4File) + '_4K.mp4';" ^
        "$newFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($mp4File), $newFileName);" ^
        "if (Test-Path \"$newFilePath\") { echo MP4 文件已存在，跳过： \"$newFilePath\"; Start-Sleep -Seconds 1; } else {" ^
        "echo 正在转换文件 \"$($file.FullName)\" 为 4K，请勿关闭窗口...;" ^
        "$args = @('-i', \"`\"$($file.FullName)`\"\", '-vf', 'scale=-1:2160');" ^
        "if ('%ffmpeg_hardware%' -ne '') { $args += '%ffmpeg_hardware%'; }" ^
        "$args += @('-preset', 'fast', '-c:a', 'aac', '-b:a', '128k', '-y', \"`\"$newFilePath`\"\");" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList $args -Wait; }}"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。
EXIT /B 0
