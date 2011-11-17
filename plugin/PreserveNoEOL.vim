" PreserveNoEOL.vim: Preserve missing EOL at the end of text files. 
"
" DEPENDENCIES:
"   - "noeol" helper executable. 
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	16-Nov-2011	file creation

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_PreserveNoEOL') || (v:version < 700)
    finish
endif
let g:loaded_PreserveNoEOL = 1

"- configuration ---------------------------------------------------------------

if ! exists('g:PreserveNoEOL_command')
    if has('win32') || has('win64')
	let g:PreserveNoEOL_command = 'perl ' . escapings#shellescape($HOME . '/bin/noeol')
    else
	let g:PreserveNoEOL_command = 'noeol'
    endif
endif


"- functions -------------------------------------------------------------------

function! PreserveNoEOL#IsPreserve()
    if exists('b:preservenoeol')
	return (b:preservenoeol != 0)
    elseif exists('g:preservenoeol')
	return (g:preservenoeol != 0)
    else
	return 0
    endif
endfunction

function! s:PreserveNoEOL( filespec )
    " Using the system() command even though we're not interested in the command
    " output. This is because on Windows GVIM, the system() call does not
    " (briefly) open a Windows shell window, but ':silent !{cmd}' does. system()
    " also does not unintentionally trigger the 'autowrite' feature. 
    let l:shell_output = system(g:PreserveNoEOL_command . ' ' . escapings#shellescape(a:filespec))

    if v:shell_error != 0
	let v:errmsg = "Failed to preserve 'noeol': " . (empty(l:shell_output) ? v:shell_error : l:shell_output) 
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    endif

    " Even though the file was changed outside of Vim, this doesn't seem to
    " trigger the |timestamp| "file changed" warning, probably because Vim
    " doesn't regard the change in the final EOL as a change. (The help text
    " says Vim re-reads in to a hidden buffer, so it probably doesn't even see
    " the change.) 
    " Therefore, no :checktime / temporary setting of 'autoread' is necessary. 
endfunction

function! s:HandleNoEOL()
    if PreserveNoEOL#IsPreserve()
	" The user has chosen to preserve the missing EOL in the last line. 
	call <SID>PreserveNoEOL(expand('<afile>'))
    else
	" The buffer write has appended the missing EOL in the last line. Vim
	" does not reset 'noeol', but I prefer to have it reflect the actual
	" file status, so that a custom 'statusline' can have a more meaningful
	" status. 
	setlocal eol
    endif
endfunction

function! s:SetPreserve()
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


"- autocmds --------------------------------------------------------------------

augroup PreserveNoEOL
    autocmd!
    autocmd BufWritePost * if ! &l:eol && ! &l:binary | call <SID>HandleNoEOL() | endif
augroup END


"- commands --------------------------------------------------------------------

command! -bar PreserveNoEOL call <SID>SetPreserve()

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
