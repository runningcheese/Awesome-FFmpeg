:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ������ļ�
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


REM �ֶ����뿪ʼʱ��ͽ���ʱ��
SET /P start_time=�����뿪ʼʱ�� (��ʽ�� 00:00:10 �� 00:10��ʱ����ſ����ã�����. �ȴ���)��
SET /P end_time=���������ʱ�䣺 

REM �Զ����ֺš�����ð�š����ķֺ��滻ΪӢ��ð��
SET start_time=%start_time:.=:%
SET start_time=%start_time:;=:%
SET start_time=%start_time:��=:%
SET start_time=%start_time:��=:%
SET end_time=%end_time:.=:%
SET end_time=%end_time:;=:%
SET end_time=%end_time:��=:%
SET end_time=%end_time:��=:%

REM �� MM:SS ת��Ϊ 00:MM:SS ��ʽ������ʼʱ�䣩
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

REM �� MM:SS ת��Ϊ 00:MM:SS ��ʽ���������ʱ�䣩
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

REM ����ʱ����duration��������ʼʱ��ͽ���ʱ��ת��Ϊ��������
CALL :time_to_seconds "%start_time%" start_seconds
CALL :time_to_seconds "%end_time%" end_seconds
SET /A duration_seconds=end_seconds-start_seconds

IF %duration_seconds% LEQ 0 (
    ECHO ����ʱ��������ڿ�ʼʱ�䣡
    PAUSE
    EXIT /B 1
)

REM ������ת��Ϊ HH:MM:SS ��ʽ
CALL :seconds_to_time "%duration_seconds%" duration

REM ����ʱ�䳤��ѡ���ļ�����ʽ�����С�� 60 ���ӣ����� MM:SS ��ʽ
FOR /F "tokens=1,2,3 delims=:" %%a IN ("%start_time%") DO (
    IF "%%a"=="00" (
        SET start_time_filename=%%b_%%c
    ) ELSE (
        SET start_time_filename=%%a_%%b_%%c
    )
)

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ����������Ƶ�ļ��������ν�ȡ��ƵƬ��Ϊ MP4 ��ʽ
    powershell -Command ^
    "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
    "foreach ($file in $files) {" ^
    "$mp4File = [System.IO.Path]::ChangeExtension($file.FullName, '.mp4');" ^
    "$mp4File = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($mp4File), [System.IO.Path]::GetFileNameWithoutExtension($mp4File) + '_%start_time_filename%' + '.mp4');" ^
    "if (Test-Path \"$mp4File\") { echo MP4 �ļ��Ѵ��ڣ������� \"$mp4File\"; Start-Sleep -Seconds 1; } else {" ^
    "echo ���ڽ�ȡ�ļ� \"$($file.FullName)\" ����رմ���...;" ^
    "Start-Process -NoNewWindow ffmpeg -ArgumentList '-ss', '%start_time%', '-t', '%duration%', '-i', \"`\"$($file.FullName)`\"\", '-c', 'copy', \"`\"$mp4File`\"\" -Wait; }}"


    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0

REM �������� HH:MM:SS ��ʽ��ʱ��ת��Ϊ����
:time_to_seconds
    SETLOCAL
    SET time_str=%~1
    FOR /F "tokens=1,2,3 delims=:." %%a IN ("%time_str%") DO (
        SET /A "hours=%%a*3600, minutes=%%b*60, seconds=%%c"
        SET /A total_seconds=hours+minutes+seconds
    )
    ENDLOCAL & SET %2=%total_seconds%
    GOTO :EOF

REM ������������ת��Ϊ HH:MM:SS ��ʽ��ʱ��
:seconds_to_time
    SETLOCAL
    SET /A h=%~1/3600, m=(%~1%%3600)/60, s=%~1%%60
    IF %h% LSS 10 SET h=0%h%
    IF %m% LSS 10 SET m=0%m%
    IF %s% LSS 10 SET s=0%s%
    ENDLOCAL & SET %2=%h%:%m%:%s%
    GOTO :EOF
