    perl << EOF
    package PreserveNoEOL;

    sub noeol
    {
	eval
	{
	    my $perms;
	    my $file = "windows.txt";
	    if (! -w $file == 1) {
		VIM::DoCommand("echomsg 'need to undo read-only'");
		my $mode = (stat($file))[2] or die "Can't stat: $!";
		$perms = sprintf('%04o', $mode & 07777);
		chmod 0777, $file or die "Can't remove read-only flag: $!";
	    }
	    open $fh, '+>>', $file or die "Can't open file: $!";
	    my $pos = tell $fh;
	    $pos > 0 or exit;
	    my $len = ($pos >= 2 ? 2 : 1);
	    sysseek $fh, $pos - $len, 0 or die "Can't seek to end: $!";
	    sysread $fh, $buf, $len or die 'No data to read?';

	    if ($buf eq "\r\n") {
		# print "truncate DOS-style CR-LF\n";
		truncate $fh, $pos - 2 or die "Can't truncate: $!";
	    } elsif(substr($buf, -1) eq "\n") {
		# print "truncate Unix-style LF\n";
		truncate $fh, $pos - 1 or die "Can't truncate: $!";
	    } elsif(substr($buf, -1) eq "\r") {
		# print "truncate Mac-style CR\n";
		truncate $fh, $pos - 1 or die "Can't truncate: $!";
	    }
	    close $fh or die "Can't close file: $!";

	    if ($perms != undef) {
		chmod $perms, $file or die "Can't restore read-only flag: $!";
	    sleep 3;
		my $mode2 = (stat($file))[2] or die "Can't stat: $!";
		my $perms2 = sprintf('%04o', $mode2 & 07777);
		if ($perms2 ne $perms) {
		    VIM::DoCommand("echomsg 'I need the read-only fix'");
		    VIM::DoCommand("perl chmod $perms, '$file' or die \"Can't restore read-only flag: \$!\"");
		} else {
		    VIM::DoCommand("echomsg 'No need for the read-only fix'");
		}
	    }
	};
	$@ =~ s/'/''/g;
	VIM::DoCommand("echomsg '$@'");
    }
    VIM::DoCommand("echomsg 'sourcing done'");
    noeol;
EOF

