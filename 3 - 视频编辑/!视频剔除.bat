@echo off

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，选择一个文件，多个文件或文件夹，拖放到此 BAT 文件图标上。
    PAUSE
    EXIT /B 1
)

REM 定义允许的文件扩展名
set "valid_exts=.mp4 .mkv .ts .wmv .avi .mpg .mpeg .mov .flv .m4v .rmvb .3gp"

REM 检查文件扩展名是否在允许的范围内
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO 奶酪提示你：当前文件格式不支持，请选择“视频”文件。
        PAUSE
        EXIT /B 1
    )

REM 手动输入开始时间和结束时间
SET /P start_time=请输入需要剔除的开始时间 (格式如 00:00:10 或 00:10，时间符号可以用；：，. 等代替)：
SET /P end_time=请输入需要剔除的结束时间 (格式如 00:00:15 或 00:15，时间符号可以用；：，. 等代替)： 

REM 自动将分号、中文冒号、中文分号替换为英文冒号
SET start_time=%start_time:.=:%
SET start_time=%start_time:;=:%
SET start_time=%start_time:；=:%
SET start_time=%start_time:：=:%
SET end_time=%end_time:.=:%
SET end_time=%end_time:;=:%
SET end_time=%end_time:；=:%
SET end_time=%end_time:：=:%

REM 处理文件夹内的所有视频文件
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径，并加双引号以处理空格和特殊符号
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有相关视频文件，并依次处理
    powershell -Command ^
    "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
    "foreach ($file in $files) {" ^
    "    $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName);" ^
    "    $part1 = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), $fileNameWithoutExt + '_part1.mp4');" ^
    "    $part2 = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), $fileNameWithoutExt + '_part2.mp4');" ^
    "    $finalOutputFile = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), $fileNameWithoutExt + '_Excluded.mp4');" ^
    "    if (Test-Path \"$finalOutputFile\") {" ^
    "        echo MP4 文件已存在，跳过： \"$finalOutputFile\"; Start-Sleep -Seconds 1;" ^
    "    } else {" ^
    "        echo 正在处理文件 \"$($file.FullName)\" 请勿关闭窗口...;" ^
    "        Start-Process ffmpeg -ArgumentList '-i', \"\"\"$($file.FullName)\"\"\", '-ss', '00:00:00', '-to', '%start_time%', '-c', 'copy', \"\"\"$part1\"\"\" -NoNewWindow -Wait;" ^
    "        Start-Process ffmpeg -ArgumentList '-i', \"\"\"$($file.FullName)\"\"\", '-ss', '%end_time%', '-c', 'copy', \"\"\"$part2\"\"\" -NoNewWindow -Wait;" ^
    "        $concatList = \"file `'$part1`'`nfile `'$part2`'\";" ^
    "        [System.Text.Encoding]::UTF8.GetBytes($concatList) | Set-Content -Path 'concat_list.txt' -NoNewline -Encoding Byte;" ^
    "        Start-Process ffmpeg -ArgumentList '-f', 'concat', '-safe', '0', '-i', 'concat_list.txt', '-c', 'copy', \"\"\"$finalOutputFile\"\"\" -NoNewWindow -Wait;" ^
    "        if (Test-Path \"$finalOutputFile\") {" ^
    "            Remove-Item -Force \"$part1\", \"$part2\", 'concat_list.txt';" ^
    "        } else {" ^
    "            echo 文件合并失败，未删除中间文件;" ^
    "        }" ^
    "    }" ^
    "}"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。
EXIT /B 0
