:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ������ļ�
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���ѡ��һ���ļ�������ļ����ļ��У��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    PAUSE
    EXIT /B 1
)

REM ����Ĭ������ģʽ�ͱ��뷽ʽ��Ĭ��Ϊ 0 
REM 0 �� CPU��1 �� N���� 2 �� A����3 �� HEVC+N����4 �� HEVC+A����
SET "gpu_codec_option=0"

REM ����ѡ������ ffmpeg ��Ӳ�����ٲ���
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"


REM ����������ȥˮӡ��λ�ã�Ĭ��Ϊ 100

SET x=100
SET y=100
SET w=100
SET h=100

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ���������ת��Ϊȥˮӡ�� MP4 ��ʽ
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp', '*.jpg', '*.jpeg', '*.png', '*.bmp', '*.gif';" ^
        "foreach ($file in $files) {" ^
        "$mp4File = [System.IO.Path]::ChangeExtension($file.FullName, '.mp4');" ^
        "$mp4File = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($mp4File), [System.IO.Path]::GetFileNameWithoutExtension($mp4File) + '_Delogo' + [System.IO.Path]::GetExtension($mp4File));" ^
        "if (Test-Path \"$mp4File\") { echo MP4 �ļ��Ѵ��ڣ������� \"$mp4File\"; Start-Sleep -Seconds 1; } else {" ^
        "echo ����ȥˮӡ�������ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "if ('%ffmpeg_hardware%' -ne '') {" ^
            "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=0', '%ffmpeg_hardware%', '-c:a', 'copy', \"`\"$mp4File`\"\" -Wait;" ^
        "} else {" ^
            "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=0', '-c:a', 'copy', \"`\"$mp4File`\"\" -Wait;" ^
        "}}}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0

