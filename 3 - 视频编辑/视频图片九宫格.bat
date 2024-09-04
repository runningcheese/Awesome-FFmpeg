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

    REM 使用 PowerShell 获取指定文件夹内的所有相关文件并依次提取视频帧为图片
    powershell -Command ^
        "$tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), 'VideoThumbnails');" ^
        "New-Item -Path $tempDir -ItemType Directory -Force | Out-Null;" ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$ffmpegOutput = ffmpeg -i \"$($file.FullName)\" 2>&1 | Select-String 'Duration';" ^
        "if ($ffmpegOutput) {" ^
        "$duration = $ffmpegOutput -match 'Duration: ([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]{2})' | Out-Null;" ^
        "$hours = [int]$matches[1]; $minutes = [int]$matches[2]; $seconds = [int]$matches[3];" ^
        "$totalSeconds = ($hours * 3600) + ($minutes * 60) + $seconds;" ^
        "$interval = [math]::Round($totalSeconds / 10);" ^
        "$filelistPath = [System.IO.Path]::Combine($tempDir, 'filelist.txt');" ^
        "Remove-Item -Path $filelistPath -ErrorAction SilentlyContinue;" ^
        "$baseName = 'image';" ^
        "for ($i = 1; $i -le 9; $i++) {" ^
        "$timecode = [TimeSpan]::FromSeconds($i * $interval).ToString('hh\:mm\:ss');" ^
        "echo 正在从 \"$($file.FullName)\" 提取图片，请勿关闭窗口...;" ^
        "$outputImage = [System.IO.Path]::Combine($tempDir, \"$baseName-$i.png\");" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-ss', $timecode, '-i', \"`\"$($file.FullName)`\"\", '-frames:v', '1', \"`\"$outputImage`\"\" -Wait;" ^
        "Add-Content -Path $filelistPath -Value \"file '$outputImage'\";" ^
        "}" ^
        "echo 正在合并图片为九宫格，请稍候...;" ^
        "$outputGrid = \"$($file.DirectoryName)\\$([System.IO.Path]::GetFileNameWithoutExtension($file.Name))-Thumbnail.png\";" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-f', 'concat', '-safe', '0', '-i', \"`\"$filelistPath`\"\", '-filter_complex', 'tile=3x3,scale=w=2048:h=-1:force_original_aspect_ratio=decrease', \"`\"$outputGrid`\"\" -Wait;" ^
        "echo 清理临时文件...;" ^
        "Remove-Item -Path \"$filelistPath\" -ErrorAction SilentlyContinue;" ^
        "Get-ChildItem -Path $tempDir -Filter \"$baseName-*.png\" | Remove-Item -ErrorAction SilentlyContinue;" ^
        "} else { echo 无法获取 \"$($file.FullName)\" 的时长信息; } }"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成，九宫格图片已导出。
EXIT /B 0
