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
        set /a "cropWidth=firstImageWidth/2"
        set "cropHeight=!firstImageHeight!"  REM ���ָ߶Ȳ���
    )
    del temp_size.txt
    goto :SizeObtained
)
:SizeObtained

REM ��ʼ������
set "index=0"

REM ��������������ļ���������ˮƽ���ȷֲ���ָ����������
for %%F in (%*) do (
    for %%j in (0,1) do (
        set "positionTag="
        if %%j==0 set "positionTag=_1���"
        if %%j==1 set "positionTag=_2�Ұ�"

        set "outputFile=%%~dpnF!positionTag!%%~xF"
        ffmpeg.exe -i "%%~fF" -vf "crop=%cropWidth%:%cropHeight%:x=%%j*%cropWidth%:y=0" "!outputFile!"
        echo �ѱ���: "!outputFile!"
    )
)

REM �����ʾ
echo ���в��к��ͼƬ�ѱ��浽ԭͼƬ��Ŀ¼�¡�
