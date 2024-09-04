:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ������ļ����ļ���
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���ѡ��һ���ļ�������ļ����ļ��У��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    PAUSE
    EXIT /B 1
)

REM ����������ļ���չ��
set "valid_exts=.bmp .png .jpg .jpeg .gif .tiff .tif .webp .ico .heic .heif .avif .svg"

REM ����ļ���չ���Ƿ�������ķ�Χ��
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO ������ʾ�㣺��ǰ�ļ���ʽ��֧�֣���ѡ��ͼƬ���ļ���
        PAUSE
        EXIT /B 1
    )

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ��������βü�Ϊ������
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.bmp','*.png','*.jpg', '*.jpeg', '*.gif', '*.tiff', '*.tif', '*.webp', '*.ico', '*.heic','*.heif', '*.avif', '*.svg';" ^
        "foreach ($file in $files) {" ^
        "$croppedFile = [System.IO.Path]::ChangeExtension($file.FullName, '_Cropped.jpg');" ^
        "if (Test-Path \"$croppedFile\") { echo �ü�����ļ��Ѵ��ڣ������� \"$croppedFile\"; Start-Sleep -Seconds 1; } else {" ^
        "echo ���ڲü��ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "$cmd = \"ffmpeg -i `\"$($file.FullName)`\" -vf `\"crop=min(iw\,ih):min(iw\,ih)`\" `\"$croppedFile`\"\";" ^
        "Start-Process -NoNewWindow -Wait -FilePath cmd.exe -ArgumentList '/c', $cmd; }}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0


