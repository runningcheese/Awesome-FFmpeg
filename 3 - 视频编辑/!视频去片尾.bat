:: by @RunningCheese�����ںţ������е�����

@echo off & setlocal enabledelayedexpansion

REM ����Ƿ������ļ����ļ���
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���ѡ��һ���ļ�������ļ����ļ��У��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    PAUSE
    EXIT /B 1
)

REM ����������ļ���չ��
set "valid_exts=.mp4 .mkv .ts .wmv .avi .mpg .mpeg .mov .flv .m4v .rmvb .3gp"

REM ����ļ���չ���Ƿ�������ķ�Χ��
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO ������ʾ�㣺��ǰ�ļ���ʽ��֧�֣���ѡ����Ƶ���ļ���
        PAUSE
        EXIT /B 1
    )

REM �������д�����ļ����ļ���·��
:process_items
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ����ļ���·��
    set "item=%~1"

    REM ������ļ��У�ʹ�� PowerShell ��ȡ������Ƶ�ļ�
    IF EXIST "%item%\" (
        FOR /F "delims=" %%i IN ('powershell -command "Get-ChildItem -Path ''%item%'' -File -Recurse -Include ''*.mp4'', ''*.mkv'', ''*.ts'', ''*.wmv'', ''*.avi'', ''*.mpg'', ''*.mpeg'', ''*.mov'', ''*.flv'', ''*.m4v'', ''*.rmvb'', ''*.3gp'' | ForEach-Object { $_.FullName }"') DO (
            CALL :process_file "%%i"
        )
    ) ELSE (
        REM ������ļ���ֱ�Ӵ�����ļ�
        CALL :process_file "%item%"
    )

    REM ������һ��������ļ����ļ���
    SHIFT
    GOTO process_items

:end
    ECHO ȫ��������ϣ�
    EXIT /B 0

REM �������ļ����ӳ���
:process_file
    set "filepath=%~1"

    REM ��ȡ�ļ�����·�����ļ�������չ��
    set "filedir=%~dp1"
    set "filename=%~n1"
    set "extension=%~x1"

    REM ��ȡ��Ƶʱ�������������
    for /f "tokens=2-5 delims=:., " %%a in ('ffmpeg -i "%filepath%" 2^>^&1 ^| find "Duration:"') do (
        set /a "t=(1%%a%%100*3600+1%%b%%100*60+1%%c%%100)*1000+1%%d0%%1000"
        set /a "t-=5000"  rem ��ȥƬβ5�루5000���룩
        set /a ms=t%%1000,t/=1000
        set /a h=t/3600,m=t%%3600/60,s=t%%60,h+=100,m+=100,s+=100,ms+=1000
        set "t=!h:~1!:!m:~1!:!s:~1!.!ms:~1!"
        
        REM ��������ļ��������� _Trailer ��׺�������浽ԭ�ļ���
        set "outputfile=%filedir%!filename!_Trailer!extension!"
        
        REM ִ�м��������浽ԭλ��
        ffmpeg -ss 00:00:00.0 -to !t! -accurate_seek -i "%filepath%" -c copy -avoid_negative_ts 1 "!outputfile!" -y
    )
    EXIT /B 0
