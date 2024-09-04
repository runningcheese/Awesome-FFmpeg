@echo off

REM ����Ƿ������ļ�
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���ѡ��һ���ļ�������ļ����ļ��У��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    PAUSE
    EXIT /B 1
)

REM �ֶ����� delogo ����
SET /P x="������ˮӡ�������ʼ x ���꣨��������Ĭ�� 100����"
SET /P y="������ˮӡ�������ʼ y ���꣨��������Ĭ�� 100����"
SET /P w="������ˮӡ����Ŀ�� w ��ȣ���������Ĭ�� 100����"
SET /P h="������ˮӡ����ĸ߶� h �߶ȣ���������Ĭ�� 100����"

REM ����û������Ƿ�Ϊ�գ����Ϊ��������Ĭ��ֵ 100
IF "%x%"=="" SET x=100
IF "%y%"=="" SET y=100
IF "%w%"=="" SET w=100
IF "%h%"=="" SET h=100


REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ��������δ���
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp', '*.jpg', '*.jpeg', '*.png', '*.bmp', '*.gif';" ^
        "foreach ($file in $files) {" ^
        "$outputFile = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), [System.IO.Path]::GetFileNameWithoutExtension($file.FullName) + '_Demo.jpg');" ^
        "if ($file.Extension -in '.mp4', '.mkv', '.ts', '.wmv', '.avi', '.mpg', '.mpeg', '.mov', '.flv', '.m4v', '.rmvb', '.3gp') {" ^
        "echo ���ڴ�����Ƶ�ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'thumbnail,delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=1', '-frames:v', '1', \"`\"$outputFile`\"\" -Wait; }" ^
        "else {" ^
        "echo ���ڴ���ͼƬ�ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=1', \"`\"$outputFile`\"\" -Wait; }}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�

REM �� delogo �������浽һ���µ� .bat �ļ���
SET saveFile="delogo_params.bat"
(
    ECHO @echo off
    ECHO REM delogo �����ű�
    ECHO SET x=%x%
    ECHO SET y=%y%
    ECHO SET w=%w%
    ECHO SET h=%h%

:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ������ļ�
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���ѡ��һ���ļ�������ļ����ļ��У��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    PAUSE
    EXIT /B 1
)

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ��������� delogo ����
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.bmp','*.png','*.jpg', '*.jpeg', '*.gif', '*.tiff', '*.tif', '*.webp', '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$mp4File = [System.IO.Path]::ChangeExtension($file.FullName, '.mp4');" ^
        "$mp4File = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($mp4File), [System.IO.Path]::GetFileNameWithoutExtension($mp4File) + '_delogo' + [System.IO.Path]::GetExtension($mp4File));" ^
        "$mediaInfo = ffmpeg -i \"$($file.FullName)\" 2>&1 | Select-String -Pattern '\d{2,5}x\d{2,5}';" ^
        "$resolution = $mediaInfo.Matches[0].Value -split 'x';" ^
        "$width = [int]$resolution[0];" ^
        "$height = [int]$resolution[1];" ^
        "if ($width -ge $height) {" ^
            "$delogo = 'delogo=x=%x%:y=%y%:w=%w%:h=%h%:show=0';" ^
        "} else {" ^
            "$delogo = 'delogo=x=772:y=90:w=258:h=84:show=0';" ^
        "}" ^
        "if (Test-Path \"$mp4File\") { echo MP4 �ļ��Ѵ��ڣ������� \"$mp4File\"; Start-Sleep -Seconds 1; } else {" ^
        "echo ���ڴ����ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', \"`\"$delogo`\"\", '-c:a', 'copy', \"`\"$mp4File`\"\" -Wait; }}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0

) > %saveFile%

ECHO delogo �����ѱ��浽 %saveFile%
EXIT /B 0
