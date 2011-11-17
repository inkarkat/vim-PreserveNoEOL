" PreserveNoEOL.vim: Preserve missing EOL at the end of text files. 
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

function! PreserveNoEOL#HandleNoEOL()
    if PreserveNoEOL#Info#IsPreserve()
	" The user has chosen to preserve the missing EOL in the last line. 
	call call(g:PreserveNoEOL_Function, [expand('<afile>')])
    else
	" The buffer write has appended the missing EOL in the last line. Vim
	" does not reset 'noeol', but I prefer to have it reflect the actual
	" file status, so that a custom 'statusline' can have a more meaningful
	" status. 
	setlocal eol
    endif
endfunction

function! PreserveNoEOL#SetPreserve()
    if &l:binary
	let v:errmsg = 'This is a binary file'
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    elseif &l:eol
	let v:errmsg = 'This file has a proper EOL ending'
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    else
	let b:preservenoeol = 1
	echomsg 'Missing EOL will be preserved'
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
