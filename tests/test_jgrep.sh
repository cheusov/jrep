# -*- coding: utf-8 -*-

unset JGREP_COLOR
unset GREP_COLOR

LC_ALL=C
export LC_ALL

GREP_CMD='jgrep'

ln -f -s text1.txt text1_copy.txt

$GREP_CMD OpenBSD text2.txt |
    cmp 'jgrep #1' \
'OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD OpenBSD - < text2.txt |
    cmp 'jgrep #1.1' \
'OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD -H OpenBSD - < text2.txt |
    cmp 'jgrep #1.2' \
'(standard input):OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
(standard input):Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD --label=stdin -He OpenBSD - < text2.txt |
    cmp 'jgrep #1.3' \
'stdin:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
stdin:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD version text1.txt text2.txt |
    cmp 'jgrep #2' \
'text1.txt:You are encouraged to test this version as thoroughly as possible.  Should you
text2.txt:version of the code.  With bug reports, please try to ensure that
'

$GREP_CMD -h version text1.txt text2.txt |
    cmp 'jgrep -h #3' \
'You are encouraged to test this version as thoroughly as possible.  Should you
version of the code.  With bug reports, please try to ensure that
'

$GREP_CMD --invert-match version text1.txt text2.txt |
    cmp 'jgrep -v #4' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:
text1.txt:Welcome to NetBSD!
text1.txt:
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:operating system, which will eventually lead to a new formal release.  This
text1.txt:snapshot may contain bugs or other unresolved issues and is not yet considered
text1.txt:release quality.  Please bear this in mind and use the system with care.
text1.txt:
text1.txt:encounter any problem, please report it back to the development team using the
text1.txt:send-pr(1) utility (requires a working MTA).  If yours is not properly set up,
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt:
text1.txt:Thank you for helping us test and improve this NetBSD branch.
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
text2.txt:
text2.txt:Please use the sendbug(1) utility to report bugs in the system.
text2.txt:Before reporting a bug, please try to reproduce it with the latest
text2.txt:enough information to reproduce the problem is enclosed, and if a
text2.txt:known fix for it exists, include that as well.
'

$GREP_CMD -v --no-filename version text1.txt text2.txt |
    cmp 'jgrep -vh #5' \
'NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!

This system is running a development snapshot of a stable branch of the NetBSD
operating system, which will eventually lead to a new formal release.  This
snapshot may contain bugs or other unresolved issues and is not yet considered
release quality.  Please bear this in mind and use the system with care.

encounter any problem, please report it back to the development team using the
send-pr(1) utility (requires a working MTA).  If yours is not properly set up,
use the web interface at: http://www.NetBSD.org/support/send-pr.html

Thank you for helping us test and improve this NetBSD branch.
OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.

Please use the sendbug(1) utility to report bugs in the system.
Before reporting a bug, please try to reproduce it with the latest
enough information to reproduce the problem is enclosed, and if a
known fix for it exists, include that as well.
'

$GREP_CMD --regexp OpenBSD -H text2.txt |
    cmp 'jgrep -regexp -H #6' \
'text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD --files-with-matches -e version text1.txt text2.txt |
    cmp 'jgrep -le #7' \
'text1.txt
text2.txt
'

$GREP_CMD -E -o '[^ ]+ please [^ ]+' text1.txt text2.txt |
    cmp 'jgrep -o #8' \
'text1.txt:problem, please report
text2.txt:bug, please try
text2.txt:reports, please try
'

$GREP_CMD --ignore-case VERSION text1.txt text2.txt |
    cmp 'jgrep -i #9' \
'text1.txt:You are encouraged to test this version as thoroughly as possible.  Should you
text2.txt:version of the code.  With bug reports, please try to ensure that
'

{ $GREP_CMD -Li openbsd text1.txt text2.txt; echo ex=$?; } |
    cmp 'jgrep -L #10' \
'text1.txt
ex=0
'

$GREP_CMD -i --files-without-match openbsd text1.txt text2.txt |
    cmp 'jgrep -L #10.1' \
'text1.txt
'

{ $GREP_CMD -Li zzzzzzzzzz text1.txt text2.txt; echo ex=$?; } |
    cmp 'jgrep -L #10.2' \
'text1.txt
text2.txt
ex=1
'

$GREP_CMD -8i '(?m:^(openbsd|netbsd).*\n\n.*$)' text1.txt text2.txt |
    cmp 'jgrep -8i #11' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!

This system is running a development snapshot of a stable branch of the NetBSD
operating system, which will eventually lead to a new formal release.  This
snapshot may contain bugs or other unresolved issues and is not yet considered
release quality.  Please bear this in mind and use the system with care.

You are encouraged to test this version as thoroughly as possible.  Should you
encounter any problem, please report it back to the development team using the
send-pr(1) utility (requires a working MTA).  If yours is not properly set up,
use the web interface at: http://www.NetBSD.org/support/send-pr.html

Thank you for helping us test and improve this NetBSD branch.

text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.

Please use the sendbug(1) utility to report bugs in the system.
Before reporting a bug, please try to reproduce it with the latest
version of the code.  With bug reports, please try to ensure that
enough information to reproduce the problem is enclosed, and if a
known fix for it exists, include that as well.

'

$GREP_CMD -8io '(?m:^(openbsd|netbsd).*\n\n.*$)' text1.txt text2.txt |
    cmp 'jgrep -8io #12.1' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

cat text1.txt text2.txt | $GREP_CMD -8io '(?m:^(openbsd|netbsd).*\n\n.*$)' |
    cmp 'jgrep -8io #12.2' \
'NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!
OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD -8iohEGP '(?m:^(openbsd|netbsd).*\n\n.*$)' text1.txt text2.txt |
    cmp 'jgrep -8ioh #13' \
'NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!
OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD -Fo '(GENERIC)' text1.txt text2.txt |
    cmp 'jgrep -Fo #14' \
'text1.txt:(GENERIC)
text2.txt:(GENERIC)
'

$GREP_CMD --fixed-strings --only-matching '(GENERIC)' text1.txt text2.txt |
    cmp 'jgrep -Fo #14.1' \
'text1.txt:(GENERIC)
text2.txt:(GENERIC)
'

$GREP_CMD -c '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jgrep -c #15' \
'text1.txt:4
text2.txt:2
'

$GREP_CMD --count '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jgrep -c #15.1' \
'text1.txt:4
text2.txt:2
'

$GREP_CMD -hc ' (well|NetBSD) ' text1.txt text2.txt |
    cmp 'jgrep -hc #16' \
'1
0
'

$GREP_CMD -c --no-filename ' (well|NetBSD) ' text1.txt text2.txt |
    cmp 'jgrep -hc #16.1' \
'1
0
'

$GREP_CMD -E --line-number  '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jgrep -c #17' \
'text1.txt:1:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:5:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:10:You are encouraged to test this version as thoroughly as possible.  Should you
text1.txt:15:Thank you for helping us test and improve this NetBSD branch.
text2.txt:7:version of the code.  With bug reports, please try to ensure that
text2.txt:9:known fix for it exists, include that as well.
'

$GREP_CMD -nh '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jgrep -nh #18' \
'1:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
5:This system is running a development snapshot of a stable branch of the NetBSD
10:You are encouraged to test this version as thoroughly as possible.  Should you
15:Thank you for helping us test and improve this NetBSD branch.
7:version of the code.  With bug reports, please try to ensure that
9:known fix for it exists, include that as well.
'

$GREP_CMD --max-count=4 '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jgrep -m #19' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:You are encouraged to test this version as thoroughly as possible.  Should you
text1.txt:Thank you for helping us test and improve this NetBSD branch.
text2.txt:version of the code.  With bug reports, please try to ensure that
text2.txt:known fix for it exists, include that as well.
'

$GREP_CMD -m3 '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jgrep -m #19.1' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:You are encouraged to test this version as thoroughly as possible.  Should you
text2.txt:version of the code.  With bug reports, please try to ensure that
text2.txt:known fix for it exists, include that as well.
'

{ $GREP_CMD -m1 '( of|that|as|well|NetBSD) ' text1.txt text2.txt; echo ex=$?; } |
    cmp 'jgrep -m #19.2' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text2.txt:version of the code.  With bug reports, please try to ensure that
ex=0
'

$GREP_CMD --line-regexp -n 'This.*|.* a' text1.txt text2.txt |
    cmp 'jgrep -x #20.1' \
'text1.txt:5:This system is running a development snapshot of a stable branch of the NetBSD
text2.txt:8:enough information to reproduce the problem is enclosed, and if a
'

$GREP_CMD -x --line-number 'This' text1.txt text2.txt |
    cmp 'jgrep -x #20.2' \
''

{ $GREP_CMD 'zzzzzzzzzz' text1.txt text2.txt; echo ex=$?; } |
    cmp 'jgrep zzzzzzzzzz #21' \
'ex=1
'

{ $GREP_CMD ')' text1.txt text2.txt; echo ex=$?; } 2>/dev/null |
    cmp 'jgrep ")" #22' \
'ex=2
'

{ $GREP_CMD 'zzz' notfoundfile.txt; echo ex=$?; } 2>/dev/null |
    cmp 'jgrep "notfoundfile.txt" #23' \
'ex=2
'

$GREP_CMD -V |
    cmp 'jgrep - #24.1' \
'jgrep-0.5.2
'

$GREP_CMD --version |
    cmp 'jgrep - #24.2' \
'jgrep-0.5.2
'

$GREP_CMD --line-buffered --with-filename OpenBSD text2.txt |
    cmp 'jgrep --line-buffered --with-filename #25' \
'text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

{ $GREP_CMD 'OpenBSD' notfoundfile.txt text2.txt; echo ex=$?; } 2>&1 |
    awk '/FileNotFoundException/ {$0 = "FileNotFoundException"} {print}' |
    cmp 'jgrep notfoundfile.txt text2.txt #26.1' \
'FileNotFoundException
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
ex=2
'

{ $GREP_CMD -s 'OpenBSD' notfoundfile.txt text2.txt; echo ex=$?; } 2>&1 |
    cmp 'jgrep notfoundfile.txt text2.txt #26.2' \
'text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
ex=2
'

{ $GREP_CMD --no-messages 'OpenBSD' notfoundfile.txt text2.txt; echo ex=$?; } 2>&1 |
    cmp 'jgrep notfoundfile.txt text2.txt #26.3' \
'text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
ex=2
'

{ $GREP_CMD --regexp OpenBSD -q text2.txt; echo ex=$?; } |
    cmp 'jgrep -regexp -q #27.1' \
'ex=0
'

{ $GREP_CMD --regexp OpenBSD --quiet text2.txt; echo ex=$?; } |
    cmp 'jgrep -regexp --quiet #27.2' \
'ex=0
'

{ $GREP_CMD --regexp OpenBSD --silent text2.txt; echo ex=$?; } |
    cmp 'jgrep -regexp --silent #27.3' \
'ex=0
'
cat text1.txt | $GREP_CMD -oH Net... |
    cmp 'jgrep <stdin> #28.1' \
'(standard input):NetBSD
(standard input):NetBSD
(standard input):NetBSD
(standard input):NetBSD
(standard input):NetBSD
'

cat text1.txt | $GREP_CMD --label=stdin -oH Net... |
    cmp 'jgrep <stdin> #28.2' \
'stdin:NetBSD
stdin:NetBSD
stdin:NetBSD
stdin:NetBSD
stdin:NetBSD
'

$GREP_CMD -e OpenBSD -e NetBSD text1.txt text2.txt |
    cmp 'jgrep -le #29' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:Welcome to NetBSD!
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt:Thank you for helping us test and improve this NetBSD branch.
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD -w bug text1.txt text2.txt |
    cmp 'jgrep -le #30.1' \
'text2.txt:Before reporting a bug, please try to reproduce it with the latest
text2.txt:version of the code.  With bug reports, please try to ensure that
'

$GREP_CMD --word-regexp bug text1.txt text2.txt |
    cmp 'jgrep -le #30.2' \
'text2.txt:Before reporting a bug, please try to reproduce it with the latest
text2.txt:version of the code.  With bug reports, please try to ensure that
'

$GREP_CMD -Hwf patterns.txt text1.txt |
    cmp 'jgrep -Hwf #31.1' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:Welcome to NetBSD!
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt:Thank you for helping us test and improve this NetBSD branch.
'

$GREP_CMD -Hw --file patterns.txt text1.txt |
    cmp 'jgrep -Hwf #31.2' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:Welcome to NetBSD!
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt:Thank you for helping us test and improve this NetBSD branch.
'

$GREP_CMD --include='*1*' --include='*[2]*' --include='text3.tx?' --recursive -e man -e 'in mind' . |
    sort |
    cmp 'jgrep -r #32.1' \
'subdir/text3.txt:FreeBSD directory layout:      man hier
subdir/text3.txt:Introduction to manual pages:  man man
subdir/text3.txt:Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
text1.txt:release quality.  Please bear this in mind and use the system with care.
'

$GREP_CMD --include='*1*' --include='*[2]*' --include 'text3.tx?' -e man -e 'in mind' text?.txt subdir/* |
    sort |
    cmp 'jgrep #32.2' \
'subdir/text3.txt:FreeBSD directory layout:      man hier
subdir/text3.txt:Introduction to manual pages:  man man
subdir/text3.txt:Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
text1.txt:release quality.  Please bear this in mind and use the system with care.
'

$GREP_CMD -ri -e NetBSD -e 'NetBSD.*$' -e 'OpenBSD.*$' -e OpenBSD \
	  -e FreeBSD -e '.*FreeBSD' -e 'Advisories.*security' -e 'welcome to \S+' \
	  --marker-start '<b>' --marker-end '</b>' \
	  --include '*.txt' --color always . |
    sort |
    cmp 'jgrep -r --include --marker-{start,end} --color always #33.1' \
'patterns.txt:<b>NetBSD</b>
patterns.txt:<b>OpenBSD</b>
subdir/text3.txt:<b>Documents installed with the system are in the /usr/local/share/doc/freebsd</b>/
subdir/text3.txt:<b>FreeBSD FAQ:           https://www.FreeBSD</b>.org/faq/
subdir/text3.txt:<b>FreeBSD Forums:        https://forums.FreeBSD</b>.org/
subdir/text3.txt:<b>FreeBSD Handbook:      https://www.FreeBSD</b>.org/handbook/
subdir/text3.txt:<b>FreeBSD</b> directory layout:      man hier
subdir/text3.txt:<b>Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd</b>-questions/
subdir/text3.txt:<b>Release Notes, Errata: https://www.FreeBSD</b>.org/releases/
subdir/text3.txt:<b>Security Advisories:   https://www.FreeBSD</b><b>.org/security</b>/
subdir/text3.txt:<b>Show the version of FreeBSD installed:  freebsd</b>-version ; uname -a
subdir/text3.txt:<b>Welcome to FreeBSD!</b>
subdir/text3.txt:<b>directory, or can be installed later with:  pkg install en-freebsd</b>-doc
text1.txt:<b>NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014</b>
text1.txt:<b>Welcome to NetBSD!</b>
text1.txt:Thank you for helping us test and improve this <b>NetBSD branch.</b>
text1.txt:This system is running a development snapshot of a stable branch of the <b>NetBSD</b>
text1.txt:use the web interface at: http://www.<b>NetBSD.org/support/send-pr.html</b>
text2.txt:<b>OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012</b>
text2.txt:<b>Welcome to OpenBSD:</b><b> The proactively secure Unix-like operating system.</b>
'

$GREP_CMD -ri -e OpenBSD --color always \
	  --marker-start '<b>' --marker-end '</b>' --include '*.txt' . |
    sort |
    cmp 'jgrep -r --include --marker-{start,end} #33.2.1' \
'patterns.txt:<b>OpenBSD</b>
text2.txt:<b>OpenBSD</b> 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to <b>OpenBSD</b>: The proactively secure Unix-like operating system.
'

$GREP_CMD --directories recurse -i -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' --include '*.txt' . |
    sort |
    cmp 'jgrep -r --include --marker-{start,end} #33.2.2' \
'patterns.txt:OpenBSD
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD --directories=recurse -i -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' \
	  --color always --include '*.txt' . | sort |
    cmp 'jgrep -r --include --marker-{start,end} #33.3' \
'patterns.txt:<b>OpenBSD</b>
text2.txt:<b>OpenBSD</b> 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to <b>OpenBSD</b>: The proactively secure Unix-like operating system.
'

$GREP_CMD -ri -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' \
	  --colour always --include '*.txt' . | sort |
    cmp 'jgrep -r --include --marker-{start,end} #33.4' \
'patterns.txt:<b>OpenBSD</b>
text2.txt:<b>OpenBSD</b> 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to <b>OpenBSD</b>: The proactively secure Unix-like operating system.
'

$GREP_CMD -ri -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' \
	  --colour=never --include '*.txt' . | sort |
    cmp 'jgrep -r --include --marker-{start,end} #33.5' \
'patterns.txt:OpenBSD
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD -ril -e BSD --exclude '*.txt' . |
    sort |
    cmp 'jgrep -r --exclude #34.1' \
'test_jgrep.sh
'

$GREP_CMD -ril -e BSD --exclude 'text1*' --exclude 'text2*' --exclude 'text3*' . |
    sort |
    cmp 'jgrep -r --exclude #34.2' \
'patterns.txt
test_jgrep.sh
'

$GREP_CMD -il -e BSD --exclude '*.txt' *.txt *.sh |
    sort |
    cmp 'jgrep -r --exclude #34.3' \
'test_jgrep.sh
'

$GREP_CMD -A4 'utility|interface' text?.txt |
    cmp 'jgrep -A/-B/-C #35.1' \
'text1.txt:send-pr(1) utility (requires a working MTA).  If yours is not properly set up,
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt-
text1.txt-Thank you for helping us test and improve this NetBSD branch.
text2.txt:Please use the sendbug(1) utility to report bugs in the system.
text2.txt-Before reporting a bug, please try to reproduce it with the latest
text2.txt-version of the code.  With bug reports, please try to ensure that
text2.txt-enough information to reproduce the problem is enclosed, and if a
text2.txt-known fix for it exists, include that as well.
'

$GREP_CMD -nB3 'utility|interface' text?.txt |
    cmp 'jgrep -A/-B/-C #35.2' \
'text1.txt-9-
text1.txt-10-You are encouraged to test this version as thoroughly as possible.  Should you
text1.txt-11-encounter any problem, please report it back to the development team using the
text1.txt:12:send-pr(1) utility (requires a working MTA).  If yours is not properly set up,
text1.txt:13:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text2.txt-2-
text2.txt-3-Welcome to OpenBSD: The proactively secure Unix-like operating system.
text2.txt-4-
text2.txt:5:Please use the sendbug(1) utility to report bugs in the system.
'

$GREP_CMD -n -B3 -A1 'utility|interface' text?.txt |
    cmp 'jgrep -A/-B/-C #35.3' \
'text1.txt-9-
text1.txt-10-You are encouraged to test this version as thoroughly as possible.  Should you
text1.txt-11-encounter any problem, please report it back to the development team using the
text1.txt:12:send-pr(1) utility (requires a working MTA).  If yours is not properly set up,
text1.txt:13:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt-14-
text2.txt-2-
text2.txt-3-Welcome to OpenBSD: The proactively secure Unix-like operating system.
text2.txt-4-
text2.txt:5:Please use the sendbug(1) utility to report bugs in the system.
text2.txt-6-Before reporting a bug, please try to reproduce it with the latest
'

$GREP_CMD -n -C 3 'utility|interface|Unix' text?.txt |
    cmp 'jgrep -A/-B/-C #35.4' \
'text1.txt-9-
text1.txt-10-You are encouraged to test this version as thoroughly as possible.  Should you
text1.txt-11-encounter any problem, please report it back to the development team using the
text1.txt:12:send-pr(1) utility (requires a working MTA).  If yours is not properly set up,
text1.txt:13:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt-14-
text1.txt-15-Thank you for helping us test and improve this NetBSD branch.
text2.txt-1-OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt-2-
text2.txt:3:Welcome to OpenBSD: The proactively secure Unix-like operating system.
text2.txt-4-
text2.txt:5:Please use the sendbug(1) utility to report bugs in the system.
text2.txt-6-Before reporting a bug, please try to reproduce it with the latest
text2.txt-7-version of the code.  With bug reports, please try to ensure that
text2.txt-8-enough information to reproduce the problem is enclosed, and if a
'

$GREP_CMD -C3 'utility|interface|Unix' text?.txt |
    cmp 'jgrep -A/-B/-C #35.5' \
'text1.txt-
text1.txt-You are encouraged to test this version as thoroughly as possible.  Should you
text1.txt-encounter any problem, please report it back to the development team using the
text1.txt:send-pr(1) utility (requires a working MTA).  If yours is not properly set up,
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt-
text1.txt-Thank you for helping us test and improve this NetBSD branch.
text2.txt-OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt-
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
text2.txt-
text2.txt:Please use the sendbug(1) utility to report bugs in the system.
text2.txt-Before reporting a bug, please try to reproduce it with the latest
text2.txt-version of the code.  With bug reports, please try to ensure that
text2.txt-enough information to reproduce the problem is enclosed, and if a
'

$GREP_CMD -hO 'schema: $1
domain: $2
path: $3
filename: $4
extension: $5' '(http)://([^/]+)([^ ]*/([^ /]+)[.]([^ .]+))' text?.txt |
    cmp 'jgrep -O #36.1' \
'schema: http
domain: www.NetBSD.org
path: /support/send-pr.html
filename: send-pr
extension: html
'

{
    $GREP_CMD -hO 'lalala: $' '(http)://([^/]+)([^ ]*/([^ /]+)[.]([^ .]+))' text?.txt 2>&1;
    echo ex=$?
} | cmp 'jgrep -O #36.2' \
'java.lang.IllegalArgumentException: Unexpected `$` in -O argument: `lalala: $`
ex=2
'

{
    $GREP_CMD -hO 'foo $n bar' '(http)://([^/]+)([^ ]*/([^ /]+)[.]([^ .]+))' text?.txt 2>&1;
    echo ex=$?
} | cmp 'jgrep -O #36.3' \
'java.lang.IllegalArgumentException: Illegal `$n` in -O argument: `foo $n bar`
ex=2
'

$GREP_CMD -rh -e snapshot --include '*.txt' . |
    sort |
    cmp 'jgrep -rh #37.1' \
'This system is running a development snapshot of a stable branch of the NetBSD
snapshot may contain bugs or other unresolved issues and is not yet considered
'

{ $GREP_CMD --colour zzz regexp text2.txt 2>&1; echo ex=$?; } |
    cmp 'jgrep --color zzz #38' \
'java.lang.IllegalArgumentException: Illegal argument `zzz` for option --color
ex=2
'

echo appapp | $GREP_CMD '(app)\1' |
    cmp 'jgrep --re-engine java #39.1' \
'appapp
'

echo appapp | $GREP_CMD --re-engine java '(app)\1' |
    cmp 'jgrep --re-engine java #39.2' \
'appapp
'

{ echo appapp | $GREP_CMD --re-engine re2j '(app)\1' 2>&1; echo ex=$?; } |
    cmp 'jgrep --re-engine java #39.3' \
'com.google.re2j.PatternSyntaxException: error parsing regexp: invalid escape sequence: `\1`
ex=2
'

{ echo appapp | $GREP_CMD -2 '(app)\1' 2>&1; echo ex=$?; } |
    cmp 'jgrep --re-engine java #39.4' \
'com.google.re2j.PatternSyntaxException: error parsing regexp: invalid escape sequence: `\1`
ex=2
'

{ echo appapp | $GREP_CMD --re-engine xxx '(app)\1' 2>&1; echo ex=$?; } |
    cmp 'jgrep --re-engine java #39.5' \
'java.lang.IllegalArgumentException: Illegal argument `xxx` for option --re-engine
ex=2
'

$GREP_CMD -r2i -e NetBSD -e 'NetBSD.*$' -e 'OpenBSD.*$' -e OpenBSD \
	  -e FreeBSD -e '.*FreeBSD' -e 'Advisories.*security' -e 'welcome to \S+' \
	  --marker-start '<b>' --marker-end '</b>' --colour=always \
	  --include '*.txt' . |
    sort |
    cmp 'jgrep -r --include --marker-{start,end} -2 #39.6' \
'patterns.txt:<b>NetBSD</b>
patterns.txt:<b>OpenBSD</b>
subdir/text3.txt:<b>Documents installed with the system are in the /usr/local/share/doc/freebsd</b>/
subdir/text3.txt:<b>FreeBSD FAQ:           https://www.FreeBSD</b>.org/faq/
subdir/text3.txt:<b>FreeBSD Forums:        https://forums.FreeBSD</b>.org/
subdir/text3.txt:<b>FreeBSD Handbook:      https://www.FreeBSD</b>.org/handbook/
subdir/text3.txt:<b>FreeBSD</b> directory layout:      man hier
subdir/text3.txt:<b>Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd</b>-questions/
subdir/text3.txt:<b>Release Notes, Errata: https://www.FreeBSD</b>.org/releases/
subdir/text3.txt:<b>Security Advisories:   https://www.FreeBSD</b><b>.org/security</b>/
subdir/text3.txt:<b>Show the version of FreeBSD installed:  freebsd</b>-version ; uname -a
subdir/text3.txt:<b>Welcome to FreeBSD!</b>
subdir/text3.txt:<b>directory, or can be installed later with:  pkg install en-freebsd</b>-doc
text1.txt:<b>NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014</b>
text1.txt:<b>Welcome to NetBSD!</b>
text1.txt:Thank you for helping us test and improve this <b>NetBSD branch.</b>
text1.txt:This system is running a development snapshot of a stable branch of the <b>NetBSD</b>
text1.txt:use the web interface at: http://www.<b>NetBSD.org/support/send-pr.html</b>
text2.txt:<b>OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012</b>
text2.txt:<b>Welcome to OpenBSD:</b><b> The proactively secure Unix-like operating system.</b>
'

$GREP_CMD -Fx 'apple' text3.txt |
    cmp 'jgrep -Fx #40.1' \
'apple
'

$GREP_CMD -Fw 'apple' text3.txt |
    cmp 'jgrep -Fw #40.2' \
'the apple
apple
'

utf8_locale=`locale -a | grep -iE 'utf-?8' -m 1 || true`
if test -n "$utf8_locale"; then
    (
	unset LC_ALL || true
	LC_CTYPE="$utf8_locale"
	export LC_CTYPE
	$GREP_CMD -Fw 'яблоко' text3.txt
    ) |
    cmp 'jgrep -Fw #40.3' \
'яблоко
'
fi

cp1251_locale=`locale -a | grep -iE '1251' -m 1 || true`
if test -n "$cp1251_locale"; then
    (
	unset LC_ALL || true
	LC_CTYPE="$cp1251_locale"
	export LC_CTYPE
	$GREP_CMD -c '\p{IsAlphabetic}+' text5.txt
    ) |
    cmp 'jgrep -c and non-standard locale #40.4' \
'2
'
fi

$GREP_CMD -8h -O '============ match ============
${1}' '(?ms:(^Welcome.*?$\n.+?[.]))' text?.txt |
    cmp 'jgrep -O #41.1' \
'============ match ============
Welcome to NetBSD!

This system is running a development snapshot of a stable branch of the NetBSD
operating system, which will eventually lead to a new formal release.
============ match ============
Welcome to OpenBSD: The proactively secure Unix-like operating system.

Please use the sendbug(1) utility to report bugs in the system.
'

$GREP_CMD -8h -O '============ match ============
${1n}' '(?ms:(^Welcome.*?$\n.+?[.]))' text?.txt |
    cmp 'jgrep -O #41.2' \
'============ match ============
Welcome to NetBSD!\n\nThis system is running a development snapshot of a stable branch of the NetBSD\noperating system, which will eventually lead to a new formal release.
============ match ============
Welcome to OpenBSD: The proactively secure Unix-like operating system.\n\nPlease use the sendbug(1) utility to report bugs in the system.
'

$GREP_CMD -8h -O '============ match ============
${1Ns}' '(?ms:(^Welcome.*?$\n.+?[.]))' text?.txt |
    cmp 'jgrep -O #41.3' \
'============ match ============
Welcome to NetBSD! This system is running a development snapshot of a stable branch of the NetBSD operating system, which will eventually lead to a new formal release.
============ match ============
Welcome to OpenBSD: The proactively secure Unix-like operating system. Please use the sendbug(1) utility to report bugs in the system.
'

$GREP_CMD This --include '*.txt' -r . | sort |
    cmp 'jgrep -r/-R #42.1' \
'text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:operating system, which will eventually lead to a new formal release.  This
'

$GREP_CMD This --include '*.txt' -R . | sort |
    cmp 'jgrep -r/-R #42.2' \
'text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:operating system, which will eventually lead to a new formal release.  This
text1_copy.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1_copy.txt:operating system, which will eventually lead to a new formal release.  This
'

$GREP_CMD -r --exclude-from=excl_patterns 'BSD' . | sort |
    cmp 'jgrep --exclude-from #43.1' \
'subdir/text3.txt:FreeBSD FAQ:           https://www.FreeBSD.org/faq/
subdir/text3.txt:FreeBSD Forums:        https://forums.FreeBSD.org/
subdir/text3.txt:FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
subdir/text3.txt:FreeBSD directory layout:      man hier
subdir/text3.txt:Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
subdir/text3.txt:Release Notes, Errata: https://www.FreeBSD.org/releases/
subdir/text3.txt:Security Advisories:   https://www.FreeBSD.org/security/
subdir/text3.txt:Show the version of FreeBSD installed:  freebsd-version ; uname -a
subdir/text3.txt:Welcome to FreeBSD!
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD --exclude-from=excl_patterns 'BSD' *.txt *.sh subdir/* | sort |
    cmp 'jgrep --exclude-from #43.2' \
'subdir/text3.txt:FreeBSD FAQ:           https://www.FreeBSD.org/faq/
subdir/text3.txt:FreeBSD Forums:        https://forums.FreeBSD.org/
subdir/text3.txt:FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
subdir/text3.txt:FreeBSD directory layout:      man hier
subdir/text3.txt:Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
subdir/text3.txt:Release Notes, Errata: https://www.FreeBSD.org/releases/
subdir/text3.txt:Security Advisories:   https://www.FreeBSD.org/security/
subdir/text3.txt:Show the version of FreeBSD installed:  freebsd-version ; uname -a
subdir/text3.txt:Welcome to FreeBSD!
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD -O '`${1}` `${2}`' '(BSD)|(zzzz)' text1.txt |
    cmp 'jgrep -O #44.1' \
'`BSD` ``
`BSD` ``
`BSD` ``
`BSD` ``
`BSD` ``
'

$GREP_CMD -O '`$1` `$2`' '(BSD)|(zzzz)' text1.txt |
    cmp 'jgrep -O #44.2' \
'`BSD` ``
`BSD` ``
`BSD` ``
`BSD` ``
`BSD` ``
'

rm text1_copy.txt

echo `pwd`/text1.txt > excl_pattern2
$GREP_CMD -l --exclude-from=excl_pattern2 'BSD' `pwd`/*.txt | sed 's,.*/,,' |
    cmp 'jgrep -O #45.1' \
'patterns.txt
text2.txt
'
rm excl_pattern2

$GREP_CMD -l --exclude=`pwd`/text1.txt 'BSD' `pwd`/*.txt | sed 's,.*/,,' |
    cmp 'jgrep -O #45.2' \
'patterns.txt
text2.txt
'

$GREP_CMD --directories=recurse -l --exclude=`pwd`/text1.txt 'BSD' `pwd`/*.txt | sed 's,.*/,,' |
    cmp 'jgrep --directories #46.1' \
'patterns.txt
text2.txt
'

$GREP_CMD --directories=skip -l --exclude=`pwd`/text1.txt 'BSD' `pwd` |
    cmp 'jgrep --directories #46.2' \
''

{ echo appapp | $GREP_CMD --directories xxx '(app)\1' 2>&1; echo ex=$?; } |
    cmp 'jgrep --directories xxx #46.3' \
'java.lang.IllegalArgumentException: Illegal argument `xxx` for option --directories
ex=2
'

{ $GREP_CMD -l --exclude=`pwd`/text1.txt 'BSD' `pwd` 2>&1;
  echo ex=$?; } |
    sed -e 's,/.*/,/path/to/jgrep/,' |
    cmp 'jgrep --directories #46.4' \
'java.io.FileNotFoundException: /path/to/jgrep/tests (Is a directory)
ex=2
'

echo abba | $GREP_CMD -e 'a+' --color always \
	  --marker-start '<b>' --marker-end '</b>' |
    sort |
    cmp 'jgrep --marker-{start,end} #47' \
'<b>a</b>bb<b>a</b>
'
