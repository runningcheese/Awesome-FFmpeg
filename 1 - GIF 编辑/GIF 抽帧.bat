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

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ��������GIF�ļ���������ȡ����֡ΪͼƬ
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.gif';" ^
        "foreach ($file in $files) {" ^
        "$outputFolder = [System.IO.Path]::Combine($file.DirectoryName, $file.BaseName);" ^
        "if (-not (Test-Path \"$outputFolder\")) { New-Item -ItemType Directory -Path \"$outputFolder\" | Out-Null; }" ^
        "echo ���ڴ� \"$($file.FullName)\" ��ȡͼƬ������رմ���...;" ^
        "ffmpeg -i \"`\"$($file.FullName)`\"\" \"$outputFolder\\image-%%2d.png\"; }"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0

