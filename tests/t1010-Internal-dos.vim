" Test Internal strategy on CR-LF line endings.

let g:PreserveNoEOL_Function = function('PreserveNoEOL#Internal#Preserve')
call AssertSameFileSize('dos.txt')
