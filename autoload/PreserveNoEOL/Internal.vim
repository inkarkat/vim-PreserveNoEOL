" Source: http://vim.wikia.com/wiki/Preserve_missing_end-of-line_at_end_of_text_files

" Preserve noeol (missing trailing eol) when saving file. In order
" to do this we need to temporarily 'set binary' for the duration of
" file writing, and for DOS line endings, add the CRs manually.
" For Mac line endings, also must join everything to one line since it doesn't
" use a LF character anywhere and 'binary' writes everything as if it were Unix.

" This works because 'eol' is set properly no matter what file format is used,
" even if it is only used when 'binary' is set.

augroup automatic_noeol
au!

au BufWritePre  * call TempSetBinaryForNoeol()
au BufWritePost * call TempRestoreBinaryForNoeol()

fun! TempSetBinaryForNoeol()
  let s:save_binary = &binary
  if ! &eol && ! &binary
    setlocal binary
    if &ff == "dos" || &ff == "mac"
      undojoin | silent 1,$-1s#$#\=nr2char(13)
    endif
    if &ff == "mac"
      let s:save_eol = &eol
      undojoin | %join!
      " mac format does not use a \n anywhere, so don't add one when writing in
      " binary (uses unix format always)
      setlocal noeol
    endif
  endif
endfun

fun! TempRestoreBinaryForNoeol()
  if ! &eol && ! s:save_binary
    if &ff == "dos"
      undojoin | silent 1,$-1s/\r$/
    elseif &ff == "mac"
      undojoin | %s/\r/\r/g
      let &l:eol = s:save_eol
    endif
    setlocal nobinary
  endif
endfun

augroup END
