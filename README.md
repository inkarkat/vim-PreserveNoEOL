PRESERVE NOEOL
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin causes Vim to omit the final newline (&lt;EOL&gt;) at the end of a
text file when you save it, if it was missing when the file was read. If the
file was read with &lt;EOL&gt; at the end, it will be saved with one. If it was read
without one, it will be saved without one.

Some (arguably broken) Windows applications (also several text editors) create
files without a final &lt;EOL&gt;, so if you have to interoperate with those, or
want to keep your commits to revision control clean of those changes, this
plugin is for you.

This works for all three line ending styles which Vim recognizes: DOS
(Windows), Unix, and traditional Mac. Multiple strategies are implemented to
handle these cases, so you can choose the one that fits you best.

### HOW IT WORKS

Except for the internal Vimscript implementation, all other strategies first
let Vim save the file as usual (with a final &lt;EOL&gt;), and then post-process (on
BufWritePost) the file contents, using file-system API functions to truncate
the final &lt;EOL&gt;.

### RELATED WORKS

The pure Vimscript implementation is based on the following VimTip:
    http://vim.wikia.com/wiki/Preserve_missing_end-of-line_at_end_of_text_files

USAGE
------------------------------------------------------------------------------

    If you always want to preserve a misssing <EOL> in text files, just put
        :let g:PreserveNoEOL = 1
    into your vimrc and you're done. If you need more fine-grained control or
    want to just turn this on in particular situations, you can use the following
    commands or the buffer-local flag b:PreserveNoEOL.

    :PreserveNoEOL          For the current buffer, the 'noeol' setting will be
                            preserved on writes. (Normally, Vim only does this for
                            'binary' files.) This has the same effect as setting
                            the marker buffer variable:
                                let b:PreserveNoEOL = 1

    :SetNoEOL               When writing the current buffer, do not append an
                            <EOL> at the end of the last line, even when there
                            used to be one. Same as
                                setlocal noeol | let b:PreserveNoEOL = 1

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-PreserveNoEOL
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim PreserveNoEOL*.vmb.gz
    :so %

On Linux / Unix systems, you also have to make the "noeol" script executable:

    :! chmod +x ~/.vim/noeol

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.022 or
  higher.
- Vim with the Python (2.x) interface or the Perl interface (optional)
- System Perl interpreter (optional)

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

This plugin supports multiple strategies for keeping the &lt;EOL&gt; off of text
files:
When Vim is compiled with +python support, a Python function is used to
strip off the trailing newline after writing the buffer. This even works with
'readonly' files.

    let g:PreserveNoEOL_Function = function('PreserveNoEOL#Python#Preserve')

When Vim is compiled with +perl support, a Perl function is used to strip
off the trailing newline after writing the buffer. This even works with
'readonly' files.

    let g:PreserveNoEOL_Function = function('PreserveNoEOL#Perl#Preserve')

Without Perl support, an similar Perl script is invoked as an external
executable. This still requires an installed Perl interpreter, but no Perl
support built into Vim.

    let g:PreserveNoEOL_Function = function('PreserveNoEOL#Executable#Preserve')

As a fallback, a pure Vimscript implementation can be used. This temporarily
sets the 'binary' option on each buffer write and messes with the line
endings.

    let g:PreserveNoEOL_Function = function('PreserveNoEOL#Internal#Preserve')

The processing can be delegated to an external executable named "noeol". It is
located in 'runtimepath' or somewhere on PATH. On Windows, this Perl script is
invoked through the Perl interpreter. You can use a different path or
executable via:

    let g:PreserveNoEOL_Command = 'path/to/executable'

INTEGRATION
------------------------------------------------------------------------------

You can influence the write behavior via the buffer-local variable
b:PreserveNoEOL. When this evaluates to true, a 'noeol' setting will be
preserved on writes.
You can use this variable in autocmds, filetype plugins or a local vimrc to
change the behavior for certain file types or files in a particular location.

If you want to indicate (e.g. in your 'statusline') that the current file's
missing EOL will be preserved, you can use the PreserveNoEOL#Info#IsPreserve()
function, which returns 1 if the plugin will preserve it; 0 otherwise.

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-PreserveNoEOL/issues or email (address below).

HISTORY
------------------------------------------------------------------------------

##### 1.02    RELEASEME
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

##### 1.01    26-Apr-2013
- In the Python strategy, support traditional Mac (CR) line endings, too.

##### 1.00    26-Apr-2013
- First published version.

##### 0.01    16-Nov-2011
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2011-2022 Ingo Karkat and the authors of the Vim Tips Wiki page -
"Preserve missing end-of-line at end of text files", which is licensed under -
  Creative Commons Attribution-Share Alike License 3.0 (Unported) (CC-BY-SA) -
  http://creativecommons.org/licenses/by-sa/3.0/ -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
