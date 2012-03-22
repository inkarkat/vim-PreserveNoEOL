" PreserveNoEOL/Info.vim: Preserve EOL information for use in statusline etc. 
"
" DEPENDENCIES:
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	18-Nov-2011	file creation

function! PreserveNoEOL#Info#IsPreserve()
    if exists('b:preservenoeol')
	return (b:preservenoeol != 0)
    elseif exists('g:preservenoeol')
	return (g:preservenoeol != 0)
    else
	return 0
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
