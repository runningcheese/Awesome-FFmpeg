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

REM ����Ƿ��������ĸ������ļ�
if "%~5"=="" (
    echo ������ʾ�㣺������ѡ�� 5 ��ͼƬ�ļ���
    pause
    exit /b 1
)

REM ��ȡ��һ��ͼƬ�Ŀ�Ⱥ͸߶ȣ����������
for %%F in (%*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "%%~fF" > temp_size.txt
    for /f "tokens=1,2 delims=," %%A in (temp_size.txt) do (
        set "firstImageWidth=%%A"
        set "firstImageHeight=%%B"
        set /a "aspectRatio=firstImageWidth*100/firstImageHeight"
    )
    del temp_size.txt
    goto :SizeObtained
)
:SizeObtained

REM ��ʼ������
set "inputFiles="
set "tempFiles="
set "index=0"
set "rowIndex=0"
set "rowFiles="
set "rowOutputs="
set "finalOutput=%~dpn1_Chessboard%~x1"

REM ��������������ļ�������������Ϊ��һ��ͼƬ�ı���
for %%F in (%*) do (
    set "tempFile=%%~dpnF_resized%%~xF"
    ffmpeg.exe -i "%%~fF" -vf "scale=w=%firstImageWidth%:h=trunc(ow*100/%aspectRatio%):force_original_aspect_ratio=increase,crop=%firstImageWidth%:%firstImageHeight%" "!tempFile!"
    set "rowFiles=!rowFiles! -i "!tempFile!""
    set "tempFiles=!tempFiles! "!tempFile!""
    set /a index+=1

    if !index! equ 4 (
        set /a rowIndex+=1
        set "rowOutput=Row!rowIndex!_Hstack.png"
        ffmpeg.exe !rowFiles! -filter_complex "hstack=inputs=4" "!rowOutput!"
        set "rowOutputs=!rowOutputs! -i "!rowOutput!""
        set "tempFiles=!tempFiles! "!rowOutput!""
        set "rowFiles="
        set "index=0"
    )
)

REM ���ͼƬ��������4�ı��������ɿհ�ͼ����
if not "!rowFiles!"=="" (
    set /a missingImages=4-!index!
    for /l %%i in (1,1,!missingImages!) do (
        ffmpeg.exe -f lavfi -i color=c=white:s=%firstImageWidth%x%firstImageHeight% -vframes 1 blank_%%i.png
        set "tempFiles=!tempFiles! blank_%%i.png"
        set "rowFiles=!rowFiles! -i blank_%%i.png"
    )

    set /a rowIndex+=1
    set "rowOutput=Row!rowIndex!_Hstack.png"
    ffmpeg.exe !rowFiles! -filter_complex "hstack=inputs=4" "!rowOutput!"
    set "rowOutputs=!rowOutputs! -i "!rowOutput!""
    set "tempFiles=!tempFiles! "!rowOutput!""
)

REM ������ˮƽƴ�ӵ��д�ֱƴ����һ��
ffmpeg.exe !rowOutputs! -filter_complex "vstack=inputs=!rowIndex!" "!finalOutput!"

echo ����ļ�: "!finalOutput!"

REM ɾ����ʱ�ļ�
for %%T in (!tempFiles!) do (
    if exist "%%~fT" del "%%~fT"
)
