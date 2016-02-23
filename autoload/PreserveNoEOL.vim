" PreserveNoEOL.vim: Preserve missing EOL at the end of text files.
"
" DEPENDENCIES:
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2011-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.02.006	05-May-2014	Use ingo#msg#ErrorMsg().
"   1.00.005	26-Apr-2013	Factor out s:ErrorMsg().
"				Receive possible error message from
"				g:PreserveNoEOL_Function and print it here
"				centrally, instead of having all strategies do
"				that on their own.
"	004	25-Mar-2012	Add :SetNoEOL command.
"	003	23-Mar-2012	Rename b:preservenoeol to b:PreserveNoEOL.
"	002	18-Nov-2011	Switched interface of Preserve() to pass
"				pre-/post-write flag instead of filespec.
"	001	18-Nov-2011	file creation

function! PreserveNoEOL#HandleNoEOL( isPostWrite )
    if PreserveNoEOL#Info#IsPreserve()
	" The user has chosen to preserve the missing EOL in the last line.
	let l:errmsg = call(g:PreserveNoEOL_Function, [a:isPostWrite])
	if ! empty(l:errmsg)
	    call ingo#msg#ErrorMsg("Failed to preserve 'noeol': " . l:errmsg)
	endif
    elseif a:isPostWrite
	" The buffer write has appended the missing EOL in the last line. Vim
	" does not reset 'noeol', but I prefer to have it reflect the actual
	" file status, so that a custom 'statusline' can have a more meaningful
	" status.
	setlocal eol
    endif
endfunction

function! PreserveNoEOL#SetPreserve( isSet )
    if &l:binary
	call ingo#msg#ErrorMsg('This is a binary file')
    elseif &l:eol
	if a:isSet
	    setlocal noeol
	    let b:PreserveNoEOL = 1
	    echomsg 'This file will be written without EOL'
	else
	    call ingo#msg#ErrorMsg('This file has a proper EOL ending')
	endif
    else
	let b:PreserveNoEOL = 1
	echomsg 'Missing EOL will be preserved'
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
