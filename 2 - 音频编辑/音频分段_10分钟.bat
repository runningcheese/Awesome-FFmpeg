:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ������ļ�
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ����뽫һ����Ƶ�ļ����뵽�� bat �ļ��ϡ�
    PAUSE
    EXIT /B 1
)

REM ��ȡ�����ļ�·��
set "input_file=%~1"

REM ��ȡ�ļ�������չ��
for %%f in ("%input_file%") do (
    set "filename_without_ext=%%~nf"
    set "file_extension=%%~xf"
)

REM �����µ��ļ������ڱ���ָ����ļ�
set "output_folder=%filename_without_ext%_split"
mkdir "%output_folder%"

REM ʹ�� FFmpeg ��ȡ�ļ�ʱ����������
for /f "tokens=*" %%i in ('ffmpeg -i "%input_file%" 2^>^&1 ^| findstr /c:"Duration"') do set duration=%%i
for /f "tokens=2 delims= " %%a in ("%duration%") do set duration=%%a
for /f "tokens=1-4 delims=:.," %%a in ("%duration%") do (
    set hours=%%a
    set minutes=%%b
    set seconds=%%c
)

REM ת��ʱ��Ϊ������
set /a total_seconds=(hours * 3600) + (minutes * 60) + seconds

REM �ָ��ļ�Ϊÿ��10����
set /a part_duration=10 * 60
set /a num_parts=total_seconds / part_duration

REM �ָ����
setlocal enabledelayedexpansion
for /l %%i in (0,1,%num_parts%) do (
    set /a start_time=%%i * part_duration

    if %%i equ %num_parts% (
        REM �������һ������10���ӵ�Ƭ��
        set /a last_duration=total_seconds-%%i*part_duration
        if !last_duration! gtr 0 (
            set /a file_num=%%i + 1
            ffmpeg -i "%input_file%" -ss !start_time! -t !last_duration! -q:a 0 "%output_folder%\%filename_without_ext%_!file_num!.mp3"
        )
    ) else (
        REM ����ÿ��10���ӵ�Ƭ��
        set /a file_num=%%i + 1
        ffmpeg -i "%input_file%" -ss !start_time! -t %part_duration% -q:a 0 "%output_folder%\%filename_without_ext%_!file_num!.mp3"
    )
)

echo �ָת����ɣ�
