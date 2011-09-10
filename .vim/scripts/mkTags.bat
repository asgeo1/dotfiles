@echo off & setlocal ENABLEEXTENSIONS

set codepath=%1
set tagfile=%2

cd %codepath%
c:\VimExe\ctags -f "C:\Program Files\Vim\vimfiles\tags\%tagfile%" -h ".php" -R --exclude="\.svn" --totals=yes --tag-relative=yes --fields=+afkst --PHP-kinds=+cf
