:: by @RunningCheese�����ںţ������е�����

@echo off

:: ��ȡ��ǰ���ں�ʱ��
set "mydate=%date:~0,4%-%date:~5,2%"
set "mytime=%time:~0,2%-%time:~3,2%-%time:~6,2%"

:: ɾ��ǰ���ո�
set mytime=%mytime: =0%

REM ����Ĭ������ģʽ�ͱ��뷽ʽ��Ĭ��Ϊ 0 
REM 0 �� CPU��1 �� N���� 2 �� A����3 �� HEVC+N����4 �� HEVC+A����
SET "gpu_codec_option=0"

REM ����ѡ������ ffmpeg ��Ӳ�����ٲ���
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

:: ִ�� ffmpeg ����
ffmpeg -f gdigrab -framerate 30 -draw_mouse 1 -offset_x 0 -offset_y 0 -video_size 2560x1440 -i desktop %ffmpeg_hardware% "%USERPROFILE%\Downloads\Record_%mydate%_%mytime%.mp4"

:: ¼�ƽ�����ʾ
echo ¼����ɣ���Ƶ�ѱ����������ļ��С�
