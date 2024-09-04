:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请将一个视频文件拖入到此 bat 文件上。
    PAUSE
    EXIT /B 1
)

REM 获取输入文件路径
set "input_file=%~1"

REM 获取文件名和扩展名
for %%f in ("%input_file%") do (
    set "filename_without_ext=%%~nf"
    set "file_extension=%%~xf"
)

REM 创建新的文件夹用于保存分割后的文件
set "output_folder=%filename_without_ext%_split"
mkdir "%output_folder%"

REM 使用 FFmpeg 获取文件时长（秒数）
for /f "tokens=*" %%i in ('ffmpeg -i "%input_file%" 2^>^&1 ^| findstr /c:"Duration"') do set duration=%%i
for /f "tokens=2 delims= " %%a in ("%duration%") do set duration=%%a
for /f "tokens=1-4 delims=:.," %%a in ("%duration%") do (
    set hours=%%a
    set minutes=%%b
    set seconds=%%c
)

REM 转换时长为总秒数
set /a total_seconds=(hours * 3600) + (minutes * 60) + seconds

REM 分割文件为每段10分钟
set /a part_duration=10 * 60
set /a num_parts=total_seconds / part_duration

REM 分割操作
setlocal enabledelayedexpansion
for /l %%i in (0,1,%num_parts%) do (
    set /a start_time=%%i * part_duration

    if %%i equ %num_parts% (
        REM 处理最后一个不足10分钟的片段
        set /a last_duration=total_seconds-%%i*part_duration
        if !last_duration! gtr 0 (
            set /a file_num=%%i + 1
            ffmpeg -i "%input_file%" -ss !start_time! -t !last_duration! -q:a 0 "%output_folder%\%filename_without_ext%_!file_num!.mp3"
        )
    ) else (
        REM 处理每个10分钟的片段
        set /a file_num=%%i + 1
        ffmpeg -i "%input_file%" -ss !start_time! -t %part_duration% -q:a 0 "%output_folder%\%filename_without_ext%_!file_num!.mp3"
    )
)

echo 分割并转换完成！
