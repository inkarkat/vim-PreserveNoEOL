let g:PreserveNoEOL = 1
runtime plugin/PreserveNoEOL.vim

let s:copyCommand = (ingo#os#IsWinOrDos() ? 'copy /B /Y' : 'cp -f')
let s:targetFilespec = 'test.txt'
function! AssertSameFileSize( inputFile )
    let l:originalSize = getfsize(a:inputFile)
    if l:originalSize <= 0
	call vimtest#BailOut('Failed to access input file: ' . a:inputFile)
	return
    endif

    " Use external copy executable because I don't fully trust the built-in
    " binary-mode readfile() / writefile() in this aspect.
    if ! vimtest#System(s:copyCommand . ' ' . shellescape(a:inputFile, 1) . ' ' . shellescape(s:targetFilespec))
	call vimtest#BailOut('External copy command failed with exit status ' . v:shell_error)
	return
    endif

    " Test execution.
    execute 'edit ++ff=' . fnamemodify(a:inputFile, ':t:r') fnameescape(s:targetFilespec)
    1substitute/.$/!/
    write

    call vimtest#StartTap()
    call vimtap#Plan(1)
    call vimtap#Is(getfsize(s:targetFilespec), l:originalSize, 'same file size after save')
    call vimtest#Quit()
endfunction
