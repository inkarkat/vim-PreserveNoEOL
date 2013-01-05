" PreserveNoEOL/Python.vim: Preserve EOL Python implementation.
"
" DEPENDENCIES:
"   - Vim with built-in Python support.
"
" Source:
"   http://stackoverflow.com/a/1663283/813602
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	05-Jan-2013	file creation

if ! has('python')
    finish
endif

if ! exists('s:isPythonInitialized')
    python << EOF
import sys
import vim

def trunc(file, new_len):
    try:
	# open with mode "append" so we have permission to modify
	# cannot open with mode "write" because that clobbers the file!
	f = open(file, "ab")
	f.truncate(new_len)
	f.close()
    except IOError:
	vim.command("let python_errmsg = 'Cannot write to file'")

def noeol():
    file = vim.eval('expand("<afile>")')
    try:
	# must have mode "b" (binary) to allow f.seek() with negative offset
	f = open(file, "rb")

	SEEK_EOF = 2
	f.seek(-2, SEEK_EOF)  # seek to two bytes before end of file

	end_pos = f.tell()
	vim.command("let foo = 'opening " + file + " to " + end_pos + "'")

	line = f.read()
	f.close()

	if line.endswith("\r\n"):
	    trunc(file, end_pos)
	elif line.endswith("\n"):
	    trunc(file, end_pos + 1)
    except IOError:
	vim.command("let python_errmsg = 'File does not exist'")
EOF
    let s:isPythonInitialized = 1
endif
function! PreserveNoEOL#Python#Preserve( isPostWrite )
    if ! a:isPostWrite
	return 1
    endif

    let l:python_errmsg = ''
    python noeol
    if ! empty(l:python_errmsg)
	let v:errmsg = "Failed to preserve 'noeol': " . l:python_errmsg
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
