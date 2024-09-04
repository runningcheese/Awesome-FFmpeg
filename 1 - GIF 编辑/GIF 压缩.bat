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

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ�������ת��Ϊ GIF ��ʽ
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.bmp','*.png','*.jpg', '*.jpeg', '*.gif', '*.tiff', '*.tif', '*.webp', '*.ico', '*.heic','*.heif', '*.avif', '*.svg', '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$gifFile = [System.IO.Path]::ChangeExtension($file.FullName, '.gif');" ^
        "$gifFile = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($gifFile), [System.IO.Path]::GetFileNameWithoutExtension($gifFile) + '_Compressed' + [System.IO.Path]::GetExtension($gifFile));" ^
        "if (Test-Path \"$gifFile\") { echo GIF �ļ��Ѵ��ڣ������� \"$gifFile\"; Start-Sleep -Seconds 1; } else {" ^
        "echo ����ת���ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', \"scale=trunc(iw/2)*2:trunc(ih/2)*2\", '-pix_fmt', 'yuv420p', '-r', '15', '-b:v', '2M', '-movflags', '+faststart', '-fs', '10M', \"`\"$gifFile`\"\" -Wait; }}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0


