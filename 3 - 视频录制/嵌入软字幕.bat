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

REM ���� ffmpeg ����
SET "ffmpeg_command=ffmpeg -i "%~nx1" -i "%~nx2" -map 0:v -map 0:a -map 1 -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language="sub" -metadata:s:s:0 title="sub" "%~dpn1_����Ļ.mp4""

REM ִ�� ffmpeg ����
%ffmpeg_command%
exit /b 0

:InvalidFirstFile
ECHO ������ʾ�㣺
ECHO ��һ���ļ��ƺ�����Ļ�ļ�����ȷ����һ��ѡ����� ��Ƶ �ļ���Ȼ����ѡ����Ļ�ļ���
pause
exit /b 1
