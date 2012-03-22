" PreserveNoEOL.vim: Preserve missing EOL at the end of text files. 
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 
"   - PreserveNoEOL.vim autoload script. 
"   - Preserve implementation like PreserveNoEOL/noeol.vim autoload script. 
"
" Copyright: (C) 2011-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	005	02-Mar-2012	FIX: Vim 7.0/1 need preloading of functions
"				referenced in Funcrefs. 
"	004	18-Nov-2011	Moved default location of "noeol" executable to
"				any 'runtimepath' directory. 
"	003	18-Nov-2011	Switched interface of Preserve() to pass
"				pre-/post-write flag instead of filespec. 
"				Add BufWritePre hook to enable pure Vimscript
"				implementation. 
"	002	18-Nov-2011	Separated preserve information, (auto)command
"				implementation functions and the strategy for
"				the actual preserve action into dedicated
"				autoload scripts. 
"	001	16-Nov-2011	file creation

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_PreserveNoEOL') || (v:version < 700)
    finish
endif
let g:loaded_PreserveNoEOL = 1

"- configuration ---------------------------------------------------------------

function! s:DefaultCommand()
    let l:noeolCommandFilespec = get(split(globpath(&runtimepath, 'noeol'), "\n"), 0, '')

    " Fall back to (hopefully) locating this somewhere on $PATH. 
    let l:noeolCommandFilespec = (empty(l:noeolCommandFilespec) ? 'noeol' : l:noeolCommandFilespec)

    let l:command = escapings#shellescape(l:noeolCommandFilespec)

    if has('win32') || has('win64')
	" Only Unix shells can directly execute the Perl script through the
	" shebang line; Windows needs an explicit invocation through the Perl
	" interpreter. 
	let l:command = 'perl ' . l:command
    endif

    return l:command
endfunction
if ! exists('g:PreserveNoEOL_command')
    let g:PreserveNoEOL_command = s:DefaultCommand()
endif
delfunction s:DefaultCommand

if ! exists('g:PreserveNoEOL_Function')
    if v:version < 702
	" Vim 7.0/1 need preloading of functions referenced in Funcrefs.
	runtime autoload/PreserveNoEOL/Internal.vim
	runtime autoload/PreserveNoEOL/noeol.vim
    endif

    let g:PreserveNoEOL_Function = (empty(g:PreserveNoEOL_command) ? function('PreserveNoEOL#Internal#Preserve') : function('PreserveNoEOL#noeol#Preserve'))
endif



"- autocmds --------------------------------------------------------------------

let s:isNoEOL = 0
augroup PreserveNoEOL
    autocmd!
    autocmd BufWritePre  * let s:isNoEOL = (! &l:eol && ! &l:binary) | if s:isNoEOL | call PreserveNoEOL#HandleNoEOL(0) | endif
    autocmd BufWritePost *                                             if s:isNoEOL | call PreserveNoEOL#HandleNoEOL(1) | endif
augroup END


"- commands --------------------------------------------------------------------

command! -bar PreserveNoEOL call PreserveNoEOL#SetPreserve()

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
