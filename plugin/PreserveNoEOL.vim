" PreserveNoEOL.vim: Preserve missing EOL at the end of text files.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - PreserveNoEOL.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/os.vim autoload script
"   - a Preserve implementation like the PreserveNoEOL/Executable.vim autoload script
"
" Copyright: (C) 2011-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.02.012	22-Sep-2014	Use ingo#compat#globpath().
"   1.02.011	13-Sep-2013	Use operating system detection functions from
"				ingo/os.vim.
"   1.02.010	08-Aug-2013	Move escapings.vim into ingo-library.
"   1.00.009	06-Jan-2013	Add (and prefer) embedded Python implementation.
"	008	25-Mar-2012	Add :SetNoEOL command.
"	007	23-Mar-2012	Add embedded Perl implementation and favor that
"				one if Vim is built with Perl support, since it
"				avoids the shell invocation and doesn't directly
"				mess with Vim's buffer contents.
"	006	23-Mar-2012	Renamed noeol.vim autoload script to
"				Executable.vim.
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
    let l:noeolCommandFilespec = get(ingo#compat#globpath(&runtimepath, 'noeol', 0, 1), 0, '')

    " Fall back to (hopefully) locating this somewhere on $PATH.
    let l:noeolCommandFilespec = (empty(l:noeolCommandFilespec) ? 'noeol' : l:noeolCommandFilespec)

    let l:command = ingo#compat#shellescape(l:noeolCommandFilespec)

    if ingo#os#IsWinOrDos()
	" Only Unix shells can directly execute the Perl script through the
	" shebang line; Windows needs an explicit invocation through the Perl
	" interpreter.
	let l:command = 'perl ' . l:command
    endif

    return l:command
endfunction
if ! exists('g:PreserveNoEOL_Command')
    let g:PreserveNoEOL_Command = s:DefaultCommand()
endif
delfunction s:DefaultCommand

if ! exists('g:PreserveNoEOL_Function')
    if v:version < 702
	" Vim 7.0/1 need preloading of functions referenced in Funcrefs.
	runtime autoload/PreserveNoEOL/Executable.vim
	runtime autoload/PreserveNoEOL/Internal.vim
	runtime autoload/PreserveNoEOL/Perl.vim
	runtime autoload/PreserveNoEOL/Python.vim
    endif

    if has('python')
	let g:PreserveNoEOL_Function = function('PreserveNoEOL#Python#Preserve')
    elseif has('perl')
	let g:PreserveNoEOL_Function = function('PreserveNoEOL#Perl#Preserve')
    elseif empty(g:PreserveNoEOL_Command)
	let g:PreserveNoEOL_Command = function('PreserveNoEOL#Internal#Preserve')
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

command! -bar PreserveNoEOL call PreserveNoEOL#SetPreserve(0)
command! -bar SetNoEOL      call PreserveNoEOL#SetPreserve(1)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
