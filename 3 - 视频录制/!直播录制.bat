:: by @RunningCheese�����ںţ������е�����

@echo off

:: ����Ĭ������ģʽ�ͱ��뷽ʽ��Ĭ��Ϊ 0 
:: 0 �� CPU��1 �� N����2 �� A����3 �� HEVC+N����4 �� HEVC+A����
SET "gpu_codec_option=0"

:: ����ѡ������ ffmpeg ��Ӳ�����ٲ���
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

:: ��ȡ��ǰ���ں�ʱ��
set "mydate=%date:~0,4%-%date:~5,2%"
set "mytime=%time:~0,2%-%time:~3,2%-%time:~6,2%"

:: ɾ��ǰ���ո�
set mytime=%mytime: =0%

:: ��ʾ�û�����ֱ������ַ
set /p stream_url=������ֱ������ַ���� Q �� Ctrl+C ��ֹ�� 

:: ����û��Ƿ�������ֱ������ַ
if "%stream_url%"=="" (
    echo ��δ����ֱ������ַ�������˳���
    pause
    exit /b
)

:: ִ�� ffmpeg ����
ffmpeg -i "%stream_url%" %ffmpeg_hardware% -c copy "%USERPROFILE%\Downloads\LiveRecord_%mydate%_%mytime%.mp4"

:: ¼�ƽ�����ʾ
echo ¼����ɣ���Ƶ�ѱ����������ء��ļ��С�
pause
