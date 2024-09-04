:: by @RunningCheese�����ںţ������е�����

@echo off
setlocal enabledelayedexpansion

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���������ѡ��������ͼƬ�ļ����Ϸŵ��� BAT �ļ�ͼ���ϣ�֧�ִ��� mp3 ��Ϊ�������֡�
    pause
    exit /b 1
)

REM ����Ƿ����������������ļ�
if "%~2"=="" (
    echo ������ʾ�㣺������ѡ��������ͼƬ�ļ���֧�ִ��� mp3 ��Ϊ�������֡�
    pause
    exit /b 1
)

REM ����ÿ��ͼƬ�ĳ���ʱ�䣬Ĭ�� 5 ��
SET Time=5

REM ׼�������ļ��б������ļ���
set "fileList="
set "outputFile="
set "audioFile="
set "imageList="

REM ��ȡ�����Ϸŵ��ļ���������������б�
set "index=0"
set "concatFilter="
for %%F in (%*) do (
    if /I "%%~xF"==".mp3" (
        REM ����ļ��� MP3����������Ϊ��������
        set "audioFile=%%F"
    ) else (
        if !index! equ 0 (
            REM ������ļ�������Ϊ��һ��ͼƬ�ļ���·�����ļ���
            set "outputFile=%%~dpF%%~nF_Portrait.mp4"
        )
        REM ��ÿ��ͼƬ�ļ������ļ��б�
        set "imageList=!imageList! %%F"
        REM ��ͼƬ�ļ�����Ϊ1080x1920�ֱ���
        ffmpeg.exe -i %%F -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setdar=9/16" -q:v 1 "temp_!index!.jpg"
        set "fileList=!fileList! -loop 1 -t %Time% -i temp_!index!.jpg"
        REM ���� concat ����������
        set "concatFilter=!concatFilter![!index!:v] "
        set /a index+=1
    )
)

REM ���û��ͼƬ�ļ����˳�
if !index! equ 0 (
    echo δ�ҵ�ͼƬ�ļ������ṩͼƬ�ļ���
    exit /b 1
)

REM ȥ�����һ���ո񣬲���ɹ�����
set "concatFilter=%concatFilter:~0,-1% concat=n=!index!:v=1:a=0,format=yuv420p,setsar=1,setdar=9/16"

REM ������Ƶ��ʱ����ÿ��ͼƬʱ�� * ͼƬ������
set /a totalDuration=index*%Time%

REM ���� ffmpeg ����
set "ffmpegCmd=ffmpeg.exe %fileList%"

REM �����������Ƶ�ļ���������� ffmpeg �����У���������Ƶѭ��
if defined audioFile (
    REM -stream_loop -1 ��������Ƶ����ѭ����ֱ����Ƶ����
    set "ffmpegCmd=!ffmpegCmd! -stream_loop -1 -i !audioFile!"
)

REM ��ӹ�������ͼƬ���ӳ���Ƶ����Ƶʱ������ͼƬʱ��
set "ffmpegCmd=!ffmpegCmd! -filter_complex "!concatFilter!" -vsync vfr -pix_fmt yuv420p"

REM �������Ƶ�ļ���ȷ����Ƶѭ��ֱ����Ƶ��������ͬ����Ƶ����Ƶ
if defined audioFile (
    set "ffmpegCmd=!ffmpegCmd! -t !totalDuration! -c:a aac -b:a 192k"
)

REM ��������ļ���
set "ffmpegCmd=!ffmpegCmd! "%outputFile%""

REM ִ�� ffmpeg ����
!ffmpegCmd!

REM ������ʱ�ļ�
for /L %%i in (0,1,!index!-1) do del temp_%%i.jpg

echo ����ļ�: !outputFile!
