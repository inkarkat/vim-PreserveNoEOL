" PreserveNoEOL/noeol.vim: Preserve EOL implementation via external "noeol"
" executable. 
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
"	002	18-Nov-2011	Switched interface of Preserve() to pass
"				pre-/post-write flag instead of filespec. 
"	001	18-Nov-2011	file creation

function! PreserveNoEOL#noeol#Preserve( isPostWrite )
    if ! a:isPostWrite
	return 1
    endif

    let l:filespec = expand('<afile>')

    " Using the system() command even though we're not interested in the command
    " output. This is because on Windows GVIM, the system() call does not
    " (briefly) open a Windows shell window, but ':silent !{cmd}' does. system()
    " also does not unintentionally trigger the 'autowrite' feature. 
    let l:shell_output = system(g:PreserveNoEOL_command . ' ' . escapings#shellescape(l:filespec))

    if v:shell_error != 0
	let v:errmsg = "Failed to preserve 'noeol': " . (empty(l:shell_output) ? v:shell_error : l:shell_output) 
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None

	return 0
    endif

    " Even though the file was changed outside of Vim, this doesn't seem to
    " trigger the |timestamp| "file changed" warning, probably because Vim
    " doesn't regard the change in the final EOL as a change. (The help text
    " says Vim re-reads in to a hidden buffer, so it probably doesn't even see
    " the change.) 
    " Therefore, no :checktime / temporary setting of 'autoread' is necessary. 
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :