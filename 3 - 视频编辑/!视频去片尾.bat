:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off & setlocal enabledelayedexpansion

REM 检查是否传入了文件或文件夹
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

REM 遍历所有传入的文件和文件夹路径
:process_items
    IF "%~1"=="" GOTO end

    REM 获取传入的文件或文件夹路径
    set "item=%~1"

    REM 如果是文件夹，使用 PowerShell 获取所有视频文件
    IF EXIST "%item%\" (
        FOR /F "delims=" %%i IN ('powershell -command "Get-ChildItem -Path ''%item%'' -File -Recurse -Include ''*.mp4'', ''*.mkv'', ''*.ts'', ''*.wmv'', ''*.avi'', ''*.mpg'', ''*.mpeg'', ''*.mov'', ''*.flv'', ''*.m4v'', ''*.rmvb'', ''*.3gp'' | ForEach-Object { $_.FullName }"') DO (
            CALL :process_file "%%i"
        )
    ) ELSE (
        REM 如果是文件，直接处理该文件
        CALL :process_file "%item%"
    )

    REM 处理下一个传入的文件或文件夹
    SHIFT
    GOTO process_items

:end
    ECHO 全部处理完毕！
    EXIT /B 0

REM 处理单个文件的子程序
:process_file
    set "filepath=%~1"

    REM 提取文件所在路径、文件名和扩展名
    set "filedir=%~dp1"
    set "filename=%~n1"
    set "extension=%~x1"

    REM 获取视频时长并计算剪辑点
    for /f "tokens=2-5 delims=:., " %%a in ('ffmpeg -i "%filepath%" 2^>^&1 ^| find "Duration:"') do (
        set /a "t=(1%%a%%100*3600+1%%b%%100*60+1%%c%%100)*1000+1%%d0%%1000"
        set /a "t-=5000"  rem 减去片尾5秒（5000毫秒）
        set /a ms=t%%1000,t/=1000
        set /a h=t/3600,m=t%%3600/60,s=t%%60,h+=100,m+=100,s+=100,ms+=1000
        set "t=!h:~1!:!m:~1!:!s:~1!.!ms:~1!"
        
        REM 生成输出文件名，加入 _Trailer 后缀，并保存到原文件夹
        set "outputfile=%filedir%!filename!_Trailer!extension!"
        
        REM 执行剪辑并保存到原位置
        ffmpeg -ss 00:00:00.0 -to !t! -accurate_seek -i "%filepath%" -c copy -avoid_negative_ts 1 "!outputfile!" -y
    )
    EXIT /B 0
