:: by @RunningCheese�����ںţ������е�����

@echo off
setlocal enabledelayedexpansion

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ�����ѡ��ͼƬ�ļ����Ϸŵ��� BAT �ļ�ͼ���ϡ�
    pause
    exit /b 1
)

REM ��ȡ��һ��ͼƬ�Ŀ�Ⱥ͸߶�
for %%F in (%*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "%%~fF" > temp_size.txt
    for /f "tokens=1,2 delims=," %%A in (temp_size.txt) do (
        set "firstImageWidth=%%A"
        set "firstImageHeight=%%B"
        set "cropWidth=!firstImageWidth!"  REM ���ֿ�Ȳ���
        set /a "cropHeight=firstImageHeight/2"
    )
    del temp_size.txt
    goto :SizeObtained
)
:SizeObtained

REM ��ʼ������
set "index=0"

REM ��������������ļ��������Ǵ�ֱ���ȷֲ���ָ����������
for %%F in (%*) do (
    for %%i in (0,1) do (
        set "positionTag="
        if %%i==0 set "positionTag=_1�ϰ�"
        if %%i==1 set "positionTag=_2�°�"

        set "outputFile=%%~dpnF!positionTag!%%~xF"
        ffmpeg.exe -i "%%~fF" -vf "crop=%cropWidth%:%cropHeight%:x=0:y=%%i*%cropHeight%" "!outputFile!"
        echo �ѱ���: "!outputFile!"
    )
)

REM �����ʾ
echo ���в��к��ͼƬ�ѱ��浽ԭͼƬ��Ŀ¼�¡�
