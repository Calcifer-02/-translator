%flex% kr.l
%bison% -dy -v kr.y
%gcc% lex.yy.c y.tab.c -o kr.exe
kr.exe
pause