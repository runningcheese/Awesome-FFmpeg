:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ�����ѡ��һ����Ƶ�ļ�����һ����Ƶ�ļ����Ϸŵ��� BAT �ļ�ͼ���ϡ�
    pause
    exit /b 1
)

REM ����Ƿ����������������ļ�
if "%~2"=="" (
    echo ������ʾ�㣺��ѡ��һ����Ƶ�ļ�����һ����Ƶ�ļ��������������� mp4 ��ʽ�ġ�
    pause
    exit /b 1
)

REM �����ļ�
set "videoFile=%~1"
set "audioFile=%~2"

REM ��ȡ������Ƶ�ļ���Ŀ¼�ͻ���
for %%F in ("%videoFile%") do (
    set "videoDir=%%~dpF"
    set "videoBaseName=%%~nF"
)

REM ����ļ�����·��
set "outputFile=%videoDir%%videoBaseName%_Merged.mp4"

REM ��� ffmpeg �Ƿ����
where /Q ffmpeg.exe
if %ERRORLEVEL% neq 0 (
    echo ������ʾ�㣺�Ҳ��� ffmpeg.exe����ȷ�� ffmpeg ����ȷ��װ�����õ�ϵͳ PATH��
    pause
    exit /b 1
)

REM ʹ�� ffmpeg �ϲ���Ƶ����Ƶ
ffmpeg.exe -i "%videoFile%" -i "%audioFile%" -vcodec copy -acodec copy -movflags faststart "%outputFile%"

REM ���ϲ��Ƿ�ɹ�
if %ERRORLEVEL% neq 0 (
    echo ������ʾ�㣺�ϲ�ʧ�ܣ����������ļ��Ƿ���ȷ��
    pause
    exit /b 1
)

echo ������ʾ�㣺�ϲ��ɹ�������ļ�Ϊ��
echo %outputFile%
