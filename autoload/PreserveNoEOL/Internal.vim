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
      "undojoin | silent 1,$-1s#$#\=nr2char(13)
      if line('$') > 1
        undojoin | exec "silent 1,$-1normal! A\<C-V>\<C-M>"
      endif
    endif
    if &ff == "mac"
      undojoin | %join!
      " mac format does not use a \n anywhere, so we don't add one when writing
      " in binary (which uses unix format always). However, inside the outer
      " "if" statement, we already know that 'noeol' is set, so no special logic
      " is needed.
    endif
  endif
endfun
 
fun! TempRestoreBinaryForNoeol()
  if ! &eol && ! s:save_binary
    if &ff == "dos"
      if line('$') > 1
        "undojoin | silent 1,$-1s/\r$//e
        silent 1,$-1s/\r$//e
      endif
    elseif &ff == "mac"
      "undojoin | %s/\r/\r/ge
      %s/\r/\r/ge
    endif
    setlocal nobinary
  endif
endfun
 
augroup END
