:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ�����ѡ��һ�� ��Ƶ �ļ�����һ�� ��Ļ �ļ����Ϸŵ��� BAT �ļ�ͼ���ϡ�
    pause
    exit /b 1
)

REM ����һ��������ļ���չ���Ƿ�Ϊ������Ļ��ʽ
SET "ext1=%~x1"
if /I "%ext1%"==".srt" (
    GOTO InvalidFirstFile
)
if /I "%ext1%"==".ass" (
    GOTO InvalidFirstFile
)
if /I "%ext1%"==".ssa" (
    GOTO InvalidFirstFile
)
if /I "%ext1%"==".sub" (
    GOTO InvalidFirstFile
)
if /I "%ext1%"==".txt" (
    GOTO InvalidFirstFile
)

REM ����Ƿ����������������ļ�
if "%~2"=="" (
    echo ������ʾ�㣺����ѡ��һ�� ��Ƶ �ļ�����һ�� ��Ļ �ļ���
    pause
    exit /b 1
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

REM ���� ffmpeg ����
SET "ffmpeg_command=ffmpeg -i "%~nx1" -vf subtitles="filename='%~nx2':force_style='FontSize=20,FontName=Microsoft Yahei'""

REM �����Ӳ�����ٲ�������ӵ�������
if not "%ffmpeg_hardware%"=="" (
    SET "ffmpeg_command=%ffmpeg_command% %ffmpeg_hardware%"
)

REM �����������
SET "ffmpeg_command=%ffmpeg_command% -x264-params crf=22 -preset fast -profile:v high "%~dpn1_Ӳ��Ļ.mp4""

REM ִ�� ffmpeg ����
%ffmpeg_command%
exit /b 0

:InvalidFirstFile
ECHO ������ʾ�㣺
ECHO ��ȷ��ѡ����Ƶ����Ļ�ļ����������Ƿ��ڡ���Ƶ��ͼ���ϵģ�Ȼ�������� BAT �ű���
pause
exit /b 1
