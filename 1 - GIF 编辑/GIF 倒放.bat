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
set "valid_exts=.gif"

REM ����ļ���չ���Ƿ�������ķ�Χ��
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO ������ʾ�㣺��ǰ�ļ���ʽ��֧�֣���ѡ��GIF���ļ���
        PAUSE
        EXIT /B 1
    )

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ����� GIF �ļ��������ε���
    powershell -Command ^
        "Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.gif' | ForEach-Object {" ^
        "$reversedGif = [System.IO.Path]::ChangeExtension($_.FullName, '_Reversed.gif');" ^
        "if (Test-Path $reversedGif) {" ^
        "Write-Host '���� GIF �ļ��Ѵ��ڣ�������' $reversedGif; Start-Sleep -Seconds 1;" ^
        "} else {" ^
        "Write-Host '���ڵ��� GIF �ļ���' $_.FullName '����رմ���...';" ^
        "ffmpeg -i $_.FullName -vf reverse $reversedGif;" ^
        "}" ^
        "}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0



