:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ�����ѡ��һ�� ��Ƶ �ļ�����һ�� ͼƬ �ļ����Ϸŵ��� BAT �ļ�ͼ���ϡ�
    pause
    exit /b 1
)

REM ����Ƿ����������������ļ�
if "%~2"=="" (
    echo ������ʾ�㣺����ѡ��һ�� ��Ƶ �ļ�����һ�� ͼƬ �ļ���
    pause
    exit /b 1
)


REM �����ļ�·���������һ����������Ƶ���ڶ�����ͼƬ��
set firstFile=%1
set secondFile=%2

REM ��ȡ�ļ���չ��
for %%X in ("%firstFile%") do set firstExt=%%~xX
for %%X in ("%secondFile%") do set secondExt=%%~xX

REM �ж��ĸ�����Ƶ�ļ�
if "%firstExt%"==".mp4" (
    set videoFile=%firstFile%
    set imageFile=%secondFile%
) else if "%secondExt%"==".mp4" (
    set videoFile=%secondFile%
    set imageFile=%firstFile%
) else (
    echo δ�ҵ���Ч����Ƶ�ļ�����ȷ���ṩ���ļ���ʽ��ȷ��
    goto :end
)

REM ��ȡ������Ƶ�ļ���Ŀ¼�ͻ���
for %%F in ("%videoFile%") do (
    set videoDir=%%~dpF
    set videoBaseName=%%~nF
)

REM ����ļ�����·��������ԭ��Ƶ�ļ���
set outputFile=%videoDir%%videoBaseName%_covered.mp4

REM ʹ�� ffmpeg �滻��Ƶ����
ffmpeg.exe ^
    -i "%videoFile%" ^
    -i "%imageFile%" ^
    -map 0 -map 1 ^
    -c copy ^
    -c:v:1 png ^
    -disposition:v:1 attached_pic ^
    "%outputFile%"

REM ��� ffmpeg �ķ���ֵ�Ƿ�ɹ�
if NOT ["%errorlevel%"]==["0"] goto :error
echo �����ɹ���ɡ�
goto :end

:error
echo ����ʧ�ܣ�����ֵ��%errorlevel%.

:end
