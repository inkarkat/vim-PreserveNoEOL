" Test Python strategy on CR-LF line endings.

call vimtest#SkipAndQuitIf(! has('python'), 'No Python support')
let g:PreserveNoEOL_Function = function('PreserveNoEOL#Python#Preserve')
call AssertSameFileSize('dos.txt')
