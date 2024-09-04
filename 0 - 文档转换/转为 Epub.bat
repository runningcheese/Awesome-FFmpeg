@echo off

REM ����Ƿ������ļ�
IF "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ���ѡ��һ���ļ�������ļ����ļ��У��Ϸŵ��� BAT �ļ�ͼ���ϡ�
    PAUSE
    EXIT /B 1
)

REM ����������ļ���չ��
set "valid_exts=.docx .html .txt .rtf .pdf .md"

REM ����ļ���չ���Ƿ�������ķ�Χ��
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO ������ʾ�㣺��ǰ�ļ���ʽ��֧�֣���ѡ���ĵ����ļ���
        PAUSE
        EXIT /B 1
    )

REM �������д�����ļ���·��
:process_folders
    IF "%~1"=="" GOTO end

    REM ��ȡ������ļ���·��
    set "folder=%~1"

    REM ʹ�� PowerShell ��ȡָ���ļ����ڵ���������ļ���������ת��Ϊ epub ��ʽ
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.docx','*.html','*.txt','*.rtf','*.pdf','*.md';" ^
        "foreach ($file in $files) {" ^
        "$epubFile = [System.IO.Path]::ChangeExtension($file.FullName, '.epub');" ^
        "if (Test-Path \"$epubFile\") { echo epub �ļ��Ѵ��ڣ������� \"$epubFile\"; Start-Sleep -Seconds 1; } else {" ^
        "echo ����ת���ļ� \"$($file.FullName)\" ����رմ���...;" ^
        "echo pandoc ����: pandoc -ArgumentList \"$($file.FullName)\", '-o', \"$epubFile\";" ^
        "Start-Process -NoNewWindow pandoc -ArgumentList \"$($file.FullName)\", '-o', \"$epubFile\" -Wait; }}"

    REM �ƶ�����һ������
    SHIFT
    GOTO process_folders

:end
ECHO ������������ɡ�
EXIT /B 0
