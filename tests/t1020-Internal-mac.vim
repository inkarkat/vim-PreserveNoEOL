" Test Internal strategy on CR line endings.

let g:PreserveNoEOL_Function = function('PreserveNoEOL#Internal#Preserve')
call AssertSameFileSize('mac.txt')
