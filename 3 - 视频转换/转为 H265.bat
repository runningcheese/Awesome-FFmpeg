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

REM ����Ĭ������ģʽ�ͱ��뷽ʽ��Ĭ��Ϊ 0 
REM 0 �� CPU��1 �� N���� 2 �� A����3 �� HEVC+N����4 �� HEVC+A����
SET "gpu_codec_option=0"

REM ����ѡ������ ffmpeg ��Ӳ�����ٲ���
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

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

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ���������ת��Ϊ H.265 ����� MP4 ��ʽ
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$outputFile = [System.IO.Path]::ChangeExtension($file.DirectoryName + '\' + $file.BaseName + '_h265', '.mp4');" ^
        "if (Test-Path \"$outputFile\") { echo �ļ��Ѵ��ڣ������� \"$outputFile\"; Start-Sleep -Seconds 1; } else {" ^
        "echo ����ת���ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "if ('%ffmpeg_hardware%' -ne '') {" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '%ffmpeg_hardware%', '-c:a', 'copy', \"`\"$outputFile`\"\" -Wait;" ^
        "} else { " ^
         "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-c:v', 'libx265', '-c:a', 'copy', \"`\"$outputFile`\"\" -Wait;}}}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0
