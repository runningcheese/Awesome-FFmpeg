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

REM �ֶ����뿪ʼʱ��ͽ���ʱ��
SET /P start_time=��������Ҫ�޳��Ŀ�ʼʱ�� (��ʽ�� 00:00:10 �� 00:10��ʱ����ſ����ã�����. �ȴ���)��
SET /P end_time=��������Ҫ�޳��Ľ���ʱ�� (��ʽ�� 00:00:15 �� 00:15��ʱ����ſ����ã�����. �ȴ���)�� 

REM �Զ����ֺš�����ð�š����ķֺ��滻ΪӢ��ð��
SET start_time=%start_time:.=:%
SET start_time=%start_time:;=:%
SET start_time=%start_time:��=:%
SET start_time=%start_time:��=:%
SET end_time=%end_time:.=:%
SET end_time=%end_time:;=:%
SET end_time=%end_time:��=:%
SET end_time=%end_time:��=:%

REM �����ļ����ڵ�������Ƶ�ļ�
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��������˫�����Դ���ո���������
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ����������Ƶ�ļ��������δ���
    powershell -Command ^
    "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
    "foreach ($file in $files) {" ^
    "    $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName);" ^
    "    $part1 = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), $fileNameWithoutExt + '_part1.mp4');" ^
    "    $part2 = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), $fileNameWithoutExt + '_part2.mp4');" ^
    "    $finalOutputFile = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), $fileNameWithoutExt + '_Excluded.mp4');" ^
    "    if (Test-Path \"$finalOutputFile\") {" ^
    "        echo MP4 �ļ��Ѵ��ڣ������� \"$finalOutputFile\"; Start-Sleep -Seconds 1;" ^
    "    } else {" ^
    "        echo ���ڴ����ļ� \"$($file.FullName)\" ����رմ���...;" ^
    "        Start-Process ffmpeg -ArgumentList '-i', \"\"\"$($file.FullName)\"\"\", '-ss', '00:00:00', '-to', '%start_time%', '-c', 'copy', \"\"\"$part1\"\"\" -NoNewWindow -Wait;" ^
    "        Start-Process ffmpeg -ArgumentList '-i', \"\"\"$($file.FullName)\"\"\", '-ss', '%end_time%', '-c', 'copy', \"\"\"$part2\"\"\" -NoNewWindow -Wait;" ^
    "        $concatList = \"file `'$part1`'`nfile `'$part2`'\";" ^
    "        [System.Text.Encoding]::UTF8.GetBytes($concatList) | Set-Content -Path 'concat_list.txt' -NoNewline -Encoding Byte;" ^
    "        Start-Process ffmpeg -ArgumentList '-f', 'concat', '-safe', '0', '-i', 'concat_list.txt', '-c', 'copy', \"\"\"$finalOutputFile\"\"\" -NoNewWindow -Wait;" ^
    "        if (Test-Path \"$finalOutputFile\") {" ^
    "            Remove-Item -Force \"$part1\", \"$part2\", 'concat_list.txt';" ^
    "        } else {" ^
    "            echo �ļ��ϲ�ʧ�ܣ�δɾ���м��ļ�;" ^
    "        }" ^
    "    }" ^
    "}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0
