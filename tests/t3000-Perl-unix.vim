" Test Perl strategy on LF line endings.

call vimtest#SkipAndQuitIf(! has('perl'), 'No Perl support')
let g:PreserveNoEOL_Function = function('PreserveNoEOL#Perl#Preserve')
call AssertSameFileSize('unix.txt')
