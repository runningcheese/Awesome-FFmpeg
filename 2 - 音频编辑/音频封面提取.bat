:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ�����ѡ��һ�� mp3 �ļ��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    pause
    exit /b 1
)

REM ����������ļ���չ��
set "valid_exts=.mp3 .wav .flac .aac .ogg .wma .m4a .alac .ape .aiff"

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

REM �����ļ�
set "audioFile=%~1"

REM ��ȡ������Ƶ�ļ���Ŀ¼�ͻ���
for %%F in ("%audioFile%") do (
    set "audioDir=%%~dpF"
    set "audioBaseName=%%~nF"
)

REM ���ͼƬ�ļ�����·��
setlocal enabledelayedexpansion
set "outputImageFile=%audioDir%%audioBaseName%_cover.jpg"

REM ʹ�� ffmpeg ��ȡ MP3 �ļ��еķ���ͼƬ
ffmpeg.exe -i "!audioFile!" -an -vcodec copy "!outputImageFile!"

ECHO ����ͼƬ����ȡ��: "!outputImageFile!"
