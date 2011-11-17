" PreserveNoEOL.vim: Preserve missing EOL at the end of text files. 
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 
"   - PreserveNoEOL.vim autoload script. 
"   - Preserve implementation like PreserveNoEOL/noeol.vim autoload script. 
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
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

if ! exists('g:PreserveNoEOL_command')
    if has('win32') || has('win64')
	let g:PreserveNoEOL_command = 'perl ' . escapings#shellescape($HOME . '/bin/noeol')
    else
	let g:PreserveNoEOL_command = 'noeol'
    endif
endif

if ! exists('g:PreserveNoEOL_Function')
    let g:PreserveNoEOL_Function = (empty(g:PreserveNoEOL_command) ? function('PreserveNoEOL#internal#Preserve') : function('PreserveNoEOL#noeol#Preserve'))
endif



"- autocmds --------------------------------------------------------------------

augroup PreserveNoEOL
    autocmd!
    autocmd BufWritePost * if ! &l:eol && ! &l:binary | call PreserveNoEOL#HandleNoEOL() | endif
augroup END


"- commands --------------------------------------------------------------------

command! -bar PreserveNoEOL call PreserveNoEOL#SetPreserve()

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
