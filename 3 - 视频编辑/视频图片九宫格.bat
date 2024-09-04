:: by @RunningCheese�����ںţ������е�����

@echo off

REM ����Ƿ������ļ�
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���ѡ��һ���ļ�������ļ����ļ��У��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    PAUSE
    EXIT /B 1
)

REM ����������ļ���չ��
set "valid_exts=.mp4 .mkv .ts .wmv .avi .mpg .mpeg .mov .flv .m4v .rmvb .3gp"

REM ����ļ���չ���Ƿ�������ķ�Χ��
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO ������ʾ�㣺��ǰ�ļ���ʽ��֧�֣���ѡ����Ƶ���ļ���
        PAUSE
        EXIT /B 1
    )

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ���������ȡ��Ƶ֡ΪͼƬ
    powershell -Command ^
        "$tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), 'VideoThumbnails');" ^
        "New-Item -Path $tempDir -ItemType Directory -Force | Out-Null;" ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$ffmpegOutput = ffmpeg -i \"$($file.FullName)\" 2>&1 | Select-String 'Duration';" ^
        "if ($ffmpegOutput) {" ^
        "$duration = $ffmpegOutput -match 'Duration: ([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]{2})' | Out-Null;" ^
        "$hours = [int]$matches[1]; $minutes = [int]$matches[2]; $seconds = [int]$matches[3];" ^
        "$totalSeconds = ($hours * 3600) + ($minutes * 60) + $seconds;" ^
        "$interval = [math]::Round($totalSeconds / 10);" ^
        "$filelistPath = [System.IO.Path]::Combine($tempDir, 'filelist.txt');" ^
        "Remove-Item -Path $filelistPath -ErrorAction SilentlyContinue;" ^
        "$baseName = 'image';" ^
        "for ($i = 1; $i -le 9; $i++) {" ^
        "$timecode = [TimeSpan]::FromSeconds($i * $interval).ToString('hh\:mm\:ss');" ^
        "echo ���ڴ� \"$($file.FullName)\" ��ȡͼƬ������رմ���...;" ^
        "$outputImage = [System.IO.Path]::Combine($tempDir, \"$baseName-$i.png\");" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-ss', $timecode, '-i', \"`\"$($file.FullName)`\"\", '-frames:v', '1', \"`\"$outputImage`\"\" -Wait;" ^
        "Add-Content -Path $filelistPath -Value \"file '$outputImage'\";" ^
        "}" ^
        "echo ���ںϲ�ͼƬΪ�Ź������Ժ�...;" ^
        "$outputGrid = \"$($file.DirectoryName)\\$([System.IO.Path]::GetFileNameWithoutExtension($file.Name))-Thumbnail.png\";" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-f', 'concat', '-safe', '0', '-i', \"`\"$filelistPath`\"\", '-filter_complex', 'tile=3x3,scale=w=2048:h=-1:force_original_aspect_ratio=decrease', \"`\"$outputGrid`\"\" -Wait;" ^
        "echo ������ʱ�ļ�...;" ^
        "Remove-Item -Path \"$filelistPath\" -ErrorAction SilentlyContinue;" ^
        "Get-ChildItem -Path $tempDir -Filter \"$baseName-*.png\" | Remove-Item -ErrorAction SilentlyContinue;" ^
        "} else { echo �޷���ȡ \"$($file.FullName)\" ��ʱ����Ϣ; } }"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɣ��Ź���ͼƬ�ѵ�����
EXIT /B 0
