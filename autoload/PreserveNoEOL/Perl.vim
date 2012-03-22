" PreserveNoEOL/Perl.vim: Preserve EOL Perl implementation.
"
" DEPENDENCIES:
"   - Vim with built-in Perl support.
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	23-Mar-2012	file creation

if ! has('perl')
    finish
endif

if ! exists('s:isPerlInitialized')
    perl << EOF
    package PreserveNoEOL;

    sub noeol
    {
	eval
	{
	    use autodie qw(open sysseek sysread truncate);

	    my $file = VIM::Eval('expand("<afile>")');
	    open my $fh, '+>>', $file;
	    my $pos = tell $fh;
	    $pos > 0 or exit;
	    my $len = ($pos >= 2 ? 2 : 1);
	    sysseek $fh, $pos - $len, 0;
	    sysread $fh, $buf, $len or die 'No data to read?';

	    if ($buf eq "\r\n") {
		# print "truncate DOS-style CR-LF\n";
		truncate $fh, $pos - 2;
	    } elsif(substr($buf, -1) eq "\n") {
		# print "truncate Unix-style LF\n";
		truncate $fh, $pos - 1;
	    } elsif(substr($buf, -1) eq "\r") {
		# print "truncate Mac-style CR\n";
		truncate $fh, $pos - 1;
	    }
	};
	$@ =~ s/'/''/g;
	VIM::DoCommand("let l:perl_errmsg = '$@'");
    }
EOF
    let s:isPerlInitialized = 1
endif
function! PreserveNoEOL#Perl#Preserve( isPostWrite )
    if ! a:isPostWrite
	return 1
    endif

    let l:perl_errmsg = ''
    perl PreserveNoEOL::noeol
    if ! empty(l:perl_errmsg)
	let v:errmsg = "Failed to preserve 'noeol': " . l:perl_errmsg
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
