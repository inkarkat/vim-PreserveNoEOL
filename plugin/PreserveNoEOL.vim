" PreserveNoEOL.vim: Preserve missing EOL at the end of text files.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - PreserveNoEOL.vim autoload script.
"   - Preserve implementation like PreserveNoEOL/Executable.vim autoload script.
"
" Copyright: (C) 2011-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	007	23-Mar-2012	Add embedded Perl implementation and favor that
"				one if Vim is built with Perl support, since it
"				avoids the shell invocation and doesn't directly
"				mess with Vim's buffer contents.
"	006	23-Mar-2012	Renamed noeol.vim autoload script to
"				Executable.vim.
"				Handle Windows executable invocation via
"				"noeol.cmd" wrapper instead of prepending the
"				Perl interpreter call. This allows for more
"				flexibility when the Perl interpreter is not
"				found in the PATH.
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
    let l:noeolCommandFilename = 'noeol' . (has('win32') || has('win64') ? '.cmd' : '')
    let l:noeolCommandFilespec = get(split(globpath(&runtimepath, l:noeolCommandFilename), "\n"), 0, '')

    " Fall back to (hopefully) locating this somewhere on the PATH.
    return escapings#shellescape(empty(l:noeolCommandFilespec) ? l:noeolCommandFilename : l:noeolCommandFilespec)
endfunction
if ! exists('g:PreserveNoEOL_command')
    let g:PreserveNoEOL_command = s:DefaultCommand()
endif
delfunction s:DefaultCommand

if ! exists('g:PreserveNoEOL_Function')
    if v:version < 702
	" Vim 7.0/1 need preloading of functions referenced in Funcrefs.
	runtime autoload/PreserveNoEOL/Executable.vim
	runtime autoload/PreserveNoEOL/Internal.vim
	runtime autoload/PreserveNoEOL/Perl.vim
    endif

    if has('perl')
	let g:PreserveNoEOL_Function = function('PreserveNoEOL#Perl#Preserve')
    elseif empty(g:PreserveNoEOL_command)
	let g:PreserveNoEOL_command = function('PreserveNoEOL#Internal#Preserve')
    else
	let g:PreserveNoEOL_Function = function('PreserveNoEOL#Executable#Preserve')
    endif
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
