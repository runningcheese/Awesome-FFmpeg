:: by @RunningCheese�����ںţ������е�����

@echo off
setlocal enabledelayedexpansion

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���������ѡ��������ͼƬ�ļ����Ϸŵ��� BAT �ļ�ͼ���ϡ�
    pause
    exit /b 1
)

REM ����Ƿ����������������ļ�
if "%~2"=="" (
    echo ������ʾ�㣺������ѡ��������ͼƬ�ļ���
    pause
    exit /b 1
)

REM ��ȡ��һ��ͼƬ�Ŀ�Ⱥ͸߶�
for %%F in (%*) do (
    REM ��ȡͼƬ�Ŀ��
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 %%F > temp_width.txt
    set /p firstImageWidth=<temp_width.txt
    del temp_width.txt

    REM ��ȡͼƬ�ĸ߶�
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 %%F > temp_height.txt
    set /p firstImageHeight=<temp_height.txt
    del temp_height.txt

    REM ����Ƿ�ɹ���ȡ���ߴ�
    if not defined firstImageWidth (
        echo �޷���ȡ��һ��ͼƬ�Ŀ�ȡ�
        pause
        exit /b 1
    )
    if not defined firstImageHeight (
        echo �޷���ȡ��һ��ͼƬ�ĸ߶ȡ�
        pause
        exit /b 1
    )

    goto :WidthObtained
)
:WidthObtained

REM ȷ���ߴ�ֵ����ȷ����
if "%firstImageWidth%"=="" (
    echo δ�ܻ�ȡͼƬ��ȣ������ļ��Ƿ���Ч��
    pause
    exit /b 1
)

REM ��ȡ��һ���ļ������ƣ���������չ����
for %%F in (%1) do set "folderName=%%~nF_Unisize"

REM �����Ե�һ���ļ���Ϊ���Ƶ��ļ���
mkdir "%folderName%"

REM ���������Ϸŵ��ļ�����������浽�´������ļ�����
for %%F in (%*) do (
    set "outputFile=%folderName%\%%~nF%%~xF"
    echo ���� %%F ������� !outputFile!
    ffmpeg.exe -i %%F -vf "scale=w=%firstImageWidth%:h=-1, pad=%firstImageWidth%:%firstImageHeight%:(ow-iw)/2:(oh-ih)/2:white" "!outputFile!" 2>nul
    if errorlevel 1 (
        echo ���� %%F ʧ�ܣ������ļ������
        pause
        exit /b 1
    )
)

echo ����ͼƬ�ѵ���Ϊ��ȣ�%firstImageWidth% �߶ȣ�%firstImageHeight% �����浽�ļ��У�%folderName%
