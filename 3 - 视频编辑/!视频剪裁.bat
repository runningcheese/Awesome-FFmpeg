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


REM 手动输入开始时间和结束时间
SET /P start_time=请输入开始时间 (格式如 00:00:10 或 00:10，时间符号可以用；：，. 等代替)：
SET /P end_time=请输入结束时间： 

REM 自动将分号、中文冒号、中文分号替换为英文冒号
SET start_time=%start_time:.=:%
SET start_time=%start_time:;=:%
SET start_time=%start_time:；=:%
SET start_time=%start_time:：=:%
SET end_time=%end_time:.=:%
SET end_time=%end_time:;=:%
SET end_time=%end_time:；=:%
SET end_time=%end_time:：=:%

REM 将 MM:SS 转换为 00:MM:SS 格式（处理开始时间）
FOR /F "tokens=1,2,3 delims=:" %%a IN ("%start_time%") DO (
    IF "%%b"=="" (
        SET start_time=00:%%a:00
    ) ELSE (
        IF "%%c"=="" (
            SET start_time=00:%%a:%%b
        ) ELSE (
            SET start_time=%%a:%%b:%%c
        )
    )
)

REM 将 MM:SS 转换为 00:MM:SS 格式（处理结束时间）
FOR /F "tokens=1,2,3 delims=:" %%a IN ("%end_time%") DO (
    IF "%%b"=="" (
        SET end_time=00:%%a:00
    ) ELSE (
        IF "%%c"=="" (
            SET end_time=00:%%a:%%b
        ) ELSE (
            SET end_time=%%a:%%b:%%c
        )
    )
)

REM 计算时长（duration），将开始时间和结束时间转化为秒进行相减
CALL :time_to_seconds "%start_time%" start_seconds
CALL :time_to_seconds "%end_time%" end_seconds
SET /A duration_seconds=end_seconds-start_seconds

IF %duration_seconds% LEQ 0 (
    ECHO 结束时间必须晚于开始时间！
    PAUSE
    EXIT /B 1
)

REM 将秒数转化为 HH:MM:SS 格式
CALL :seconds_to_time "%duration_seconds%" duration

REM 根据时间长度选择文件名格式，如果小于 60 分钟，则用 MM:SS 格式
FOR /F "tokens=1,2,3 delims=:" %%a IN ("%start_time%") DO (
    IF "%%a"=="00" (
        SET start_time_filename=%%b_%%c
    ) ELSE (
        SET start_time_filename=%%a_%%b_%%c
    )
)

REM 遍历所有传入的文件夹路径
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有相关视频文件，并依次截取视频片段为 MP4 格式
    powershell -Command ^
    "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
    "foreach ($file in $files) {" ^
    "$mp4File = [System.IO.Path]::ChangeExtension($file.FullName, '.mp4');" ^
    "$mp4File = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($mp4File), [System.IO.Path]::GetFileNameWithoutExtension($mp4File) + '_%start_time_filename%' + '.mp4');" ^
    "if (Test-Path \"$mp4File\") { echo MP4 文件已存在，跳过： \"$mp4File\"; Start-Sleep -Seconds 1; } else {" ^
    "echo 正在截取文件 \"$($file.FullName)\" 请勿关闭窗口...;" ^
    "Start-Process -NoNewWindow ffmpeg -ArgumentList '-ss', '%start_time%', '-t', '%duration%', '-i', \"`\"$($file.FullName)`\"\", '-c', 'copy', \"`\"$mp4File`\"\" -Wait; }}"


    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。
EXIT /B 0

REM 函数：将 HH:MM:SS 格式的时间转换为秒数
:time_to_seconds
    SETLOCAL
    SET time_str=%~1
    FOR /F "tokens=1,2,3 delims=:." %%a IN ("%time_str%") DO (
        SET /A "hours=%%a*3600, minutes=%%b*60, seconds=%%c"
        SET /A total_seconds=hours+minutes+seconds
    )
    ENDLOCAL & SET %2=%total_seconds%
    GOTO :EOF

REM 函数：将秒数转换为 HH:MM:SS 格式的时间
:seconds_to_time
    SETLOCAL
    SET /A h=%~1/3600, m=(%~1%%3600)/60, s=%~1%%60
    IF %h% LSS 10 SET h=0%h%
    IF %m% LSS 10 SET m=0%m%
    IF %s% LSS 10 SET s=0%s%
    ENDLOCAL & SET %2=%h%:%m%:%s%
    GOTO :EOF
