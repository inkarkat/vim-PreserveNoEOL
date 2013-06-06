" Test Python strategy on CR line endings.

call vimtest#SkipAndQuitIf(! has('perl'), 'No Python support')
let g:PreserveNoEOL_Function = function('PreserveNoEOL#Python#Preserve')
call AssertSameFileSize('mac.txt')
