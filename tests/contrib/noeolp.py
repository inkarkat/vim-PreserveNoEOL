import os, stat, sys

def trunc(file, new_len):
    try:
	fileAtt = os.stat(file)[0]
	if (not fileAtt & stat.S_IWRITE):
	    # File is read-only, so make it writeable
	    os.chmod(file, stat.S_IWRITE)

	# open with mode "append" so we have permission to modify
	# cannot open with mode "write" because that clobbers the file!
	f = open(file, "ab")
	f.truncate(new_len)
	f.close()

	if (not fileAtt & stat.S_IWRITE):
	    os.chmod(file, fileAtt)
    except IOError as err:
	print str(err)

def noeol():
    file = "windows.txt"
    try:
	# must have mode "b" (binary) to allow f.seek() with negative offset
	f = open(file, "rb")

	SEEK_EOF = 2
	f.seek(-2, SEEK_EOF)  # seek to two bytes before end of file

	end_pos = f.tell()
	print "opening " + file + " to " + str(end_pos)

	line = f.read()
	f.close()

	if line.endswith("\r\n"):
	    trunc(file, end_pos)
	elif line.endswith("\n"):
	    trunc(file, end_pos + 1)
    except IOError as err:
	print 'File does not exist', err

print "start"
noeol()
print "end"
