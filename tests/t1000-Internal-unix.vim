" Test Internal strategy on LF line endings.

let g:PreserveNoEOL_Function = function('PreserveNoEOL#Internal#Preserve')
call AssertSameFileSize('unix.txt')
