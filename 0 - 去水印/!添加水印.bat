:: by @RunningCheese�����ںţ������е�����

@echo off
setlocal enabledelayedexpansion

REM ����Ƿ������ļ�
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���ѡ��һ���ļ�������ļ����ļ��У��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    PAUSE
    EXIT /B 1
)

REM �������֡�ͼƬ������·��
SET TEXT=@�����е�����
SET IMAGE_PATH="D:/CommandLine/SendTo+/Assets/Logo.png"
SET FONT_PATH="D:/CommandLine/SendTo+/Assets/Fontfile.ttf"

REM ��������ˮӡλ�úʹ�С
SET LandscapeTextX=1620
SET LandscapeTextY=50
SET LandscapeTextSize=36

REM ����ͼƬˮӡλ��
SET LandscapeImageX=1540
SET LandscapeImageY=32

REM ��������ˮӡλ�úʹ�С
SET PortraitTextX=730
SET PortraitTextY=60
SET PortraitTextSize=42

REM ����ͼƬˮӡλ��
SET PortraitImageX=650
SET PortraitImageY=45

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ�������Ƶ�ļ�����������Ƶ�������ˮӡ
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$mediaInfo = ffmpeg -i \"$($file.FullName)\" 2>&1 | Select-String -Pattern '\d{2,5}x\d{2,5}';" ^
        "$resolution = $mediaInfo.Matches[0].Value -split 'x';" ^
        "$width = [int]$resolution[0];" ^
        "$height = [int]$resolution[1];" ^
        "$mp4File = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), [System.IO.Path]::GetFileNameWithoutExtension($file.FullName) + '_Watermark.mp4');" ^
        "if (-Not (Test-Path $mp4File)) {" ^
        "echo �������ˮӡ��������Ƶ�ļ� $($file.FullName) ����رմ���...;" ^
        "if ($width -ge $height) {" ^
        "ffmpeg -i \"$($file.FullName)\" -i \"%IMAGE_PATH%\" -filter_complex \"drawtext=text='%TEXT%':fontfile='%FONT_PATH%':x=%LandscapeTextX%:y=%LandscapeTextY%:fontsize=%LandscapeTextSize%:fontcolor=white:shadowx=2:shadowy=2:shadowcolor=DimGray:alpha=0.9,overlay=%LandscapeImageX%:%LandscapeImageY%\" -c:a copy \"$mp4File\" -y;" ^
        "} else {" ^
        "ffmpeg -i \"$($file.FullName)\" -i \"%IMAGE_PATH%\" -filter_complex \"drawtext=text='%TEXT%':fontfile='%FONT_PATH%':x=%PortraitTextX%:y=%PortraitTextY%:fontsize=%PortraitTextSize%:fontcolor=white:shadowx=2:shadowy=2:shadowcolor=DimGray:alpha=0.9,overlay=%PortraitImageX%:%PortraitImageY%\" -c:a copy \"$mp4File\" -y;" ^
        "}}}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0
