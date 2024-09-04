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

REM ��ȡ��һ��ͼƬ�Ŀ��
for %%F in (%*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "%%~fF" > temp_width.txt
    set /p firstImageWidth=<temp_width.txt
    del temp_width.txt
    goto :WidthObtained
)
:WidthObtained

REM ׼�������ļ��б������ļ���
set "inputFiles="
set "outputFile="
set "tempFiles="

REM ��ȡ�����Ϸŵ��ļ���������Ϊ��һ��ͼƬ�Ŀ��
set "index=0"
for %%F in (%*) do (
    if !index! equ 0 (
        set "outputFile=%%~dpnF_Vstack%%~xF"
    )
    set "tempFile=%%~dpnF_resized%%~xF"
    ffmpeg.exe -i "%%~fF" -vf "scale=%firstImageWidth%:-1" "!tempFile!"
    set "inputFiles=!inputFiles! -i "!tempFile!""
    set "tempFiles=!tempFiles! "!tempFile!""
    set /a index+=1
)

REM �ϳ�ͼƬ
ffmpeg.exe %inputFiles% -filter_complex "vstack=inputs=%index%" "%outputFile%"

echo ����ļ�: "%outputFile%"

REM ɾ����ʱ�ļ�
for %%T in (!tempFiles!) do (
    if exist "%%~fT" del "%%~fT"
)

