echo off 
echo 当前目录："%cd%" >FileList.txt
tree /f >>FileList.txt 
echo 目录树已生成，按任意键查看。

start FileList.txt