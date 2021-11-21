" Test Executable strategy on LF line endings.

call vimtest#SkipAndQuitIf(empty(g:PreserveNoEOL_Command), 'No external executable found')
let g:PreserveNoEOL_Function = function('PreserveNoEOL#Executable#Preserve')
call AssertSameFileSize('unix.txt')
