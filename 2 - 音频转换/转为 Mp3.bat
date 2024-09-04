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
set "valid_exts=.mp3 .wav .flac .aac .ogg .wma .m4a .alac .ape .aiff .mp4 .mkv .ts .wmv .avi .mpg .mpeg .mov .flv .m4v .rmvb .3gp"

REM ����ļ���չ���Ƿ�������ķ�Χ��
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO ������ʾ�㣺��ǰ�ļ���ʽ��֧�֣���ѡ����Ƶ������Ƶ���ļ���
        PAUSE
        EXIT /B 1
    )

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ�������ת��Ϊ MP3 ��ʽ����Ƕ�����
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp3', '*.wav', '*.m4a', '*.ogg', '*.aac', '*.flac', '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$mp3File = [System.IO.Path]::ChangeExtension($file.FullName, '.mp3');" ^
        "$coverImage = [System.IO.Path]::ChangeExtension($file.FullName, '.jpg');" ^
        "if (Test-Path \"$mp3File\") { echo MP3 �ļ��Ѵ��ڣ������� \"$mp3File\"; Start-Sleep -Seconds 1; } else {" ^
        "echo ����ת���ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "if ($file.Extension -match 'mp4|mkv|ts|wmv|avi|mpg|mpeg|mov|flv|m4v|rmvb|3gp') {" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-q:v', '2', '-vf', 'thumbnail', '-frames:v', '1', \"`\"$coverImage`\"\" -Wait; }" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-i', \"`\"$coverImage`\"\", '-q:a', '0', '-map', '0:a', '-map', '1:v', '-c:v', 'copy', '-id3v2_version', '3', '-metadata:s:v', 'title=\"Album cover\"', '-metadata:s:v', 'comment=\"Cover (front)\"', \"`\"$mp3File`\"\" -Wait; }" ^
        "if (Test-Path \"$coverImage\") { Remove-Item \"$coverImage\"; }}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0



