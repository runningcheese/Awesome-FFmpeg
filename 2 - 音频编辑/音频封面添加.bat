:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ�����ѡ��һ�� mp3 �ļ�����һ�� ͼƬ �ļ����Ϸŵ��� BAT �ļ�ͼ���ϡ�
    pause
    exit /b 1
)

REM ����Ƿ����������������ļ�
if "%~2"=="" (
    echo ������ʾ�㣺����ѡ��һ�� mp3 �ļ�����һ�� ͼƬ �ļ���
    pause
    exit /b 1
)

REM �����ļ�
set audioFile=%1
set imageFile=%2

REM ��ȡ������Ƶ�ļ���Ŀ¼�ͻ���
for %%F in ("%audioFile%") do (
    set audioDir=%%~dpF
    set audioBaseName=%%~nF
)

REM ����ļ�����·��
set outputFile=%audioDir%%audioBaseName%_with_cover.mp3

REM ʹ�� ffmpeg �� mp3 �ļ����ͼƬ����
ffmpeg.exe -i "%audioFile%" -i "%imageFile%" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "%outputFile%"
