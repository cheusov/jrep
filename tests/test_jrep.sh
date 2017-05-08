# -*- coding: utf-8 -*-

unset JREP_COLOR

LC_ALL=C
export LC_ALL

JREP_CMD='jrep'

ln -f -s text1.txt text1_copy.txt

{ echo '' | $JREP_CMD 2>&1; echo ex=$?; } |
    cmp 'jrep #0.1' \
'Usage: jrep [OPTIONS]... PATTERN [FILES...]
Try '"'"'jrep --help'"'"' for more information.
ex=2
'

{ echo '' | $JREP_CMD -h 2>&1; echo ex=$?; } |
    cmp 'jrep #0.2' \
'Usage: jrep [OPTIONS]... PATTERN [FILES...]
Try '"'"'jrep --help'"'"' for more information.
ex=2
'

$JREP_CMD OpenBSD text2.txt |
    cmp 'jrep #1' \
'OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD OpenBSD - < text2.txt |
    cmp 'jrep #1.1' \
'OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD -H OpenBSD - < text2.txt |
    cmp 'jrep #1.2' \
'(standard input):OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
(standard input):Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD --label=stdin -He OpenBSD - < text2.txt |
    cmp 'jrep #1.3' \
'stdin:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
stdin:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD version text1.txt text2.txt |
    cmp 'jrep #2' \
'text1.txt:You are encouraged to test this version as thoroughly as possible.  Should you
text2.txt:version of the code.  With bug reports, please try to ensure that
'

$JREP_CMD -h version text1.txt text2.txt |
    cmp 'jrep -h #3' \
'You are encouraged to test this version as thoroughly as possible.  Should you
version of the code.  With bug reports, please try to ensure that
'

$JREP_CMD --invert-match version text1.txt text2.txt |
    cmp 'jrep -v #4' \
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

$JREP_CMD -v --no-filename version text1.txt text2.txt |
    cmp 'jrep -vh #5' \
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

$JREP_CMD --regexp OpenBSD -H text2.txt |
    cmp 'jrep -regexp -H #6' \
'text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD --files-with-matches -e version text1.txt text2.txt |
    cmp 'jrep -le #7' \
'text1.txt
text2.txt
'

$JREP_CMD -E -o '[^ ]+ please [^ ]+' text1.txt text2.txt |
    cmp 'jrep -o #8' \
'text1.txt:problem, please report
text2.txt:bug, please try
text2.txt:reports, please try
'

$JREP_CMD --ignore-case VERSION text1.txt text2.txt |
    cmp 'jrep -i #9' \
'text1.txt:You are encouraged to test this version as thoroughly as possible.  Should you
text2.txt:version of the code.  With bug reports, please try to ensure that
'

{ $JREP_CMD -Li openbsd text1.txt text2.txt; echo ex=$?; } |
    cmp 'jrep -L #10' \
'text1.txt
ex=0
'

$JREP_CMD -i --files-without-match openbsd text1.txt text2.txt |
    cmp 'jrep -L #10.1' \
'text1.txt
'

{ $JREP_CMD -Li zzzzzzzzzz text1.txt text2.txt; echo ex=$?; } |
    cmp 'jrep -L #10.2' \
'text1.txt
text2.txt
ex=1
'

$JREP_CMD -8i '(?m:^(openbsd|netbsd).*\n\n.*$)' text1.txt text2.txt |
    cmp 'jrep -8i #11' \
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

$JREP_CMD -8io '(?m:^(openbsd|netbsd).*\n\n.*$)' text1.txt text2.txt |
    cmp 'jrep -8io #12.1' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

cat text1.txt text2.txt | $JREP_CMD -8io '(?m:^(openbsd|netbsd).*\n\n.*$)' |
    cmp 'jrep -8io #12.2' \
'NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!
OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD -8iohEGP '(?m:^(openbsd|netbsd).*\n\n.*$)' text1.txt text2.txt |
    cmp 'jrep -8ioh #13' \
'NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!
OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD -Fo '(GENERIC)' text1.txt text2.txt |
    cmp 'jrep -Fo #14' \
'text1.txt:(GENERIC)
text2.txt:(GENERIC)
'

$JREP_CMD --fixed-strings --only-matching '(GENERIC)' text1.txt text2.txt |
    cmp 'jrep -Fo #14.1' \
'text1.txt:(GENERIC)
text2.txt:(GENERIC)
'

$JREP_CMD -c '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jrep -c #15' \
'text1.txt:4
text2.txt:2
'

$JREP_CMD --count '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jrep -c #15.1' \
'text1.txt:4
text2.txt:2
'

$JREP_CMD -hc ' (well|NetBSD) ' text1.txt text2.txt |
    cmp 'jrep -hc #16' \
'1
0
'

$JREP_CMD -c --no-filename ' (well|NetBSD) ' text1.txt text2.txt |
    cmp 'jrep -hc #16.1' \
'1
0
'

$JREP_CMD -E --line-number  '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jrep -c #17' \
'text1.txt:1:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:5:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:10:You are encouraged to test this version as thoroughly as possible.  Should you
text1.txt:15:Thank you for helping us test and improve this NetBSD branch.
text2.txt:7:version of the code.  With bug reports, please try to ensure that
text2.txt:9:known fix for it exists, include that as well.
'

$JREP_CMD -nh '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jrep -nh #18' \
'1:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
5:This system is running a development snapshot of a stable branch of the NetBSD
10:You are encouraged to test this version as thoroughly as possible.  Should you
15:Thank you for helping us test and improve this NetBSD branch.
7:version of the code.  With bug reports, please try to ensure that
9:known fix for it exists, include that as well.
'

$JREP_CMD --max-count=4 '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jrep -m #19' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:You are encouraged to test this version as thoroughly as possible.  Should you
text1.txt:Thank you for helping us test and improve this NetBSD branch.
text2.txt:version of the code.  With bug reports, please try to ensure that
text2.txt:known fix for it exists, include that as well.
'

$JREP_CMD -m3 '( of|that|as|well|NetBSD) ' text1.txt text2.txt |
    cmp 'jrep -m #19.1' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:You are encouraged to test this version as thoroughly as possible.  Should you
text2.txt:version of the code.  With bug reports, please try to ensure that
text2.txt:known fix for it exists, include that as well.
'

{ $JREP_CMD -m1 '( of|that|as|well|NetBSD) ' text1.txt text2.txt; echo ex=$?; } |
    cmp 'jrep -m #19.2' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text2.txt:version of the code.  With bug reports, please try to ensure that
ex=0
'

$JREP_CMD --line-regexp -n 'This.*|.* a' text1.txt text2.txt |
    cmp 'jrep -x #20.1' \
'text1.txt:5:This system is running a development snapshot of a stable branch of the NetBSD
text2.txt:8:enough information to reproduce the problem is enclosed, and if a
'

$JREP_CMD -x --line-number 'This' text1.txt text2.txt |
    cmp 'jrep -x #20.2' \
''

{ $JREP_CMD 'zzzzzzzzzz' text1.txt text2.txt; echo ex=$?; } |
    cmp 'jrep zzzzzzzzzz #21' \
'ex=1
'

{ $JREP_CMD ')' text1.txt text2.txt; echo ex=$?; } 2>/dev/null |
    cmp 'jrep ")" #22' \
'ex=2
'

{ $JREP_CMD 'zzz' notfoundfile.txt; echo ex=$?; } 2>/dev/null |
    cmp 'jrep "notfoundfile.txt" #23' \
'ex=2
'

hide_version (){
    sed -e 's/[0-9][0-9]*\([.][0-9][0-9]*\)*/NNN/' "$@"
}

$JREP_CMD -V | hide_version |
    cmp 'jrep - #24.1' \
'jrep-NNN
'

$JREP_CMD --version | hide_version |
    cmp 'jrep - #24.2' \
'jrep-NNN
'

$JREP_CMD --line-buffered --with-filename OpenBSD text2.txt |
    cmp 'jrep --line-buffered --with-filename #25' \
'text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

{ $JREP_CMD 'OpenBSD' notfoundfile.txt text2.txt; echo ex=$?; } 2>&1 |
    awk '/FileNotFoundException/ {$0 = "FileNotFoundException"} {print}' |
    cmp 'jrep notfoundfile.txt text2.txt #26.1' \
'FileNotFoundException
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
ex=2
'

{ $JREP_CMD -s 'OpenBSD' notfoundfile.txt text2.txt; echo ex=$?; } 2>&1 |
    cmp 'jrep notfoundfile.txt text2.txt #26.2' \
'text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
ex=2
'

{ $JREP_CMD --no-messages 'OpenBSD' notfoundfile.txt text2.txt; echo ex=$?; } 2>&1 |
    cmp 'jrep notfoundfile.txt text2.txt #26.3' \
'text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
ex=2
'

{ $JREP_CMD --regexp OpenBSD -q text2.txt; echo ex=$?; } |
    cmp 'jrep -regexp -q #27.1' \
'ex=0
'

{ $JREP_CMD --regexp OpenBSD --quiet text2.txt; echo ex=$?; } |
    cmp 'jrep -regexp --quiet #27.2' \
'ex=0
'

{ $JREP_CMD --regexp OpenBSD --silent text2.txt; echo ex=$?; } |
    cmp 'jrep -regexp --silent #27.3' \
'ex=0
'
cat text1.txt | $JREP_CMD -oH Net... |
    cmp 'jrep <stdin> #28.1' \
'(standard input):NetBSD
(standard input):NetBSD
(standard input):NetBSD
(standard input):NetBSD
(standard input):NetBSD
'

cat text1.txt | $JREP_CMD --label=stdin -oH Net... |
    cmp 'jrep <stdin> #28.2' \
'stdin:NetBSD
stdin:NetBSD
stdin:NetBSD
stdin:NetBSD
stdin:NetBSD
'

$JREP_CMD -e OpenBSD -e NetBSD text1.txt text2.txt |
    cmp 'jrep -le #29' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:Welcome to NetBSD!
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt:Thank you for helping us test and improve this NetBSD branch.
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD -w bug text1.txt text2.txt |
    cmp 'jrep -le #30.1' \
'text2.txt:Before reporting a bug, please try to reproduce it with the latest
text2.txt:version of the code.  With bug reports, please try to ensure that
'

$JREP_CMD --word-regexp bug text1.txt text2.txt |
    cmp 'jrep -le #30.2' \
'text2.txt:Before reporting a bug, please try to reproduce it with the latest
text2.txt:version of the code.  With bug reports, please try to ensure that
'

$JREP_CMD -Hwf patterns.txt text1.txt |
    cmp 'jrep -Hwf #31.1' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:Welcome to NetBSD!
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt:Thank you for helping us test and improve this NetBSD branch.
'

$JREP_CMD -Hw --file patterns.txt text1.txt |
    cmp 'jrep -Hwf #31.2' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014
text1.txt:Welcome to NetBSD!
text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:use the web interface at: http://www.NetBSD.org/support/send-pr.html
text1.txt:Thank you for helping us test and improve this NetBSD branch.
'

$JREP_CMD --include='*1*' --include='*[2]*' --include='text3.tx?' --recursive -e man -e 'in mind' . |
    sort |
    cmp 'jrep -r #32.1' \
'subdir/text3.txt:FreeBSD directory layout:      man hier
subdir/text3.txt:Introduction to manual pages:  man man
subdir/text3.txt:Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
text1.txt:release quality.  Please bear this in mind and use the system with care.
'

$JREP_CMD --include='*1*' --include='*[2]*' --include 'text3.tx?' -e man -e 'in mind' text?.txt subdir/* |
    sort |
    cmp 'jrep #32.2' \
'subdir/text3.txt:FreeBSD directory layout:      man hier
subdir/text3.txt:Introduction to manual pages:  man man
subdir/text3.txt:Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
text1.txt:release quality.  Please bear this in mind and use the system with care.
'

$JREP_CMD -ri -e NetBSD -e 'NetBSD.*$' -e 'OpenBSD.*$' -e OpenBSD \
	  -e FreeBSD -e '.*FreeBSD' -e 'Advisories.*security' -e 'welcome to \S+' \
	  --marker-start '<b>' --marker-end '</b>' \
	  --include '*.txt' --color always . |
    sort |
    cmp 'jrep -r --include --marker-{start,end} --color always #33.1' \
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

$JREP_CMD -ri -e OpenBSD --color always \
	  --marker-start '<b>' --marker-end '</b>' --include '*.txt' . |
    sort |
    cmp 'jrep -r --include --marker-{start,end} #33.2.1' \
'patterns.txt:<b>OpenBSD</b>
text2.txt:<b>OpenBSD</b> 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to <b>OpenBSD</b>: The proactively secure Unix-like operating system.
'

$JREP_CMD --directories recurse -i -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' --include '*.txt' . |
    sort |
    cmp 'jrep -r --include --marker-{start,end} #33.2.2' \
'patterns.txt:OpenBSD
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD -drecurse -i -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' --include '*.txt' . |
    sort |
    cmp 'jrep -r --include --marker-{start,end} #33.2.3' \
'patterns.txt:OpenBSD
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD --directories=recurse -i -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' \
	  --color always --include '*.txt' . | sort |
    cmp 'jrep -r --include --marker-{start,end} #33.3.1' \
'patterns.txt:<b>OpenBSD</b>
text2.txt:<b>OpenBSD</b> 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to <b>OpenBSD</b>: The proactively secure Unix-like operating system.
'

$JREP_CMD -d recurse -i -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' \
	  --color always --include '*.txt' . | sort |
    cmp 'jrep -r --include --marker-{start,end} #33.3.2' \
'patterns.txt:<b>OpenBSD</b>
text2.txt:<b>OpenBSD</b> 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to <b>OpenBSD</b>: The proactively secure Unix-like operating system.
'

$JREP_CMD -ri -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' \
	  --colour always --include '*.txt' . | sort |
    cmp 'jrep -r --include --marker-{start,end} #33.4' \
'patterns.txt:<b>OpenBSD</b>
text2.txt:<b>OpenBSD</b> 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to <b>OpenBSD</b>: The proactively secure Unix-like operating system.
'

$JREP_CMD -ri -e OpenBSD \
	  --marker-start '<b>' --marker-end '</b>' \
	  --colour=never --include '*.txt' . | sort |
    cmp 'jrep -r --include --marker-{start,end} #33.5' \
'patterns.txt:OpenBSD
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
text2.txt:Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$JREP_CMD -ril -e BSD --exclude '*.txt' . |
    sort |
    cmp 'jrep -r --exclude #34.1' \
'test_jrep.sh
'

$JREP_CMD -ril -e BSD --exclude 'text1*' --exclude 'text2*' --exclude 'text3*' . |
    sort |
    cmp 'jrep -r --exclude #34.2' \
'patterns.txt
test_jrep.sh
'

$JREP_CMD -il -e BSD --exclude '*.txt' *.txt *.sh |
    sort |
    cmp 'jrep -r --exclude #34.3' \
'test_jrep.sh
'

$JREP_CMD -A4 'utility|interface' text?.txt |
    cmp 'jrep -A/-B/-C #35.1' \
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

$JREP_CMD -nB3 'utility|interface' text?.txt |
    cmp 'jrep -A/-B/-C #35.2' \
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

$JREP_CMD -n -B3 -A1 'utility|interface' text?.txt |
    cmp 'jrep -A/-B/-C #35.3' \
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

$JREP_CMD -n -C 3 'utility|interface|Unix' text?.txt |
    cmp 'jrep -A/-B/-C #35.4' \
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

$JREP_CMD -C3 'utility|interface|Unix' text?.txt |
    cmp 'jrep -A/-B/-C #35.5' \
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

$JREP_CMD -hO 'schema: $1
domain: $2
path: $3
filename: $4
extension: $5' '(http)://([^/]+)([^ ]*/([^ /]+)[.]([^ .]+))' text?.txt |
    cmp 'jrep -O #36.1' \
'schema: http
domain: www.NetBSD.org
path: /support/send-pr.html
filename: send-pr
extension: html
'

{
    $JREP_CMD -hO 'lalala: $' '(http)://([^/]+)([^ ]*/([^ /]+)[.]([^ .]+))' text?.txt 2>&1;
    echo ex=$?
} | cmp 'jrep -O #36.2' \
'Unexpected `$` in -O argument: `lalala: $`
ex=2
'

{
    $JREP_CMD -hO 'foo $n bar' '(http)://([^/]+)([^ ]*/([^ /]+)[.]([^ .]+))' text?.txt 2>&1;
    echo ex=$?
} | cmp 'jrep -O #36.3' \
'Illegal `$n` in -O argument: `foo $n bar`
ex=2
'

$JREP_CMD -rh -e snapshot --include '*.txt' . |
    sort |
    cmp 'jrep -rh #37.1' \
'This system is running a development snapshot of a stable branch of the NetBSD
snapshot may contain bugs or other unresolved issues and is not yet considered
'

{ $JREP_CMD --colour zzz regexp text2.txt 2>&1; echo ex=$?; } |
    cmp 'jrep --color zzz #38' \
'Illegal argument `zzz` for option --color
ex=2
'

echo appapp | $JREP_CMD '(app)\1' |
    cmp 'jrep --re-engine java #39.1' \
'appapp
'

echo appapp | $JREP_CMD --re-engine java '(app)\1' |
    cmp 'jrep --re-engine java #39.2' \
'appapp
'

{ echo appapp | $JREP_CMD --re-engine re2j '(app)\1' 2>&1; echo ex=$?; } |
    cmp 'jrep --re-engine java #39.3' \
'error parsing regexp: invalid escape sequence: `\1`
ex=2
'

{ echo appapp | $JREP_CMD -2 '(app)\1' 2>&1; echo ex=$?; } |
    cmp 'jrep --re-engine java #39.4' \
'error parsing regexp: invalid escape sequence: `\1`
ex=2
'

{ echo appapp | $JREP_CMD --re-engine xxx '(app)\1' 2>&1; echo ex=$?; } |
    cmp 'jrep --re-engine java #39.5' \
'Illegal argument `xxx` for option --re-engine
ex=2
'

$JREP_CMD -r2i -e NetBSD -e 'NetBSD.*$' -e 'OpenBSD.*$' -e OpenBSD \
	  -e FreeBSD -e '.*FreeBSD' -e 'Advisories.*security' -e 'welcome to \S+' \
	  --marker-start '<b>' --marker-end '</b>' --colour=always \
	  --include '*.txt' . |
    sort |
    cmp 'jrep -r --include --marker-{start,end} -2 #39.6' \
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

$JREP_CMD -Fx 'apple' text3.txt |
    cmp 'jrep -Fx #40.1' \
'apple
'

$JREP_CMD -Fw 'apple' text3.txt |
    cmp 'jrep -Fw #40.2' \
'the apple
apple
'

utf8_locale=`locale -a | grep -iE 'utf-?8' -m 1 || true`
if test -n "$utf8_locale"; then
    (
	unset LC_ALL || true
	LC_CTYPE="$utf8_locale"
	export LC_CTYPE
	$JREP_CMD -Fw 'яблоко' text3.txt
    ) |
    cmp 'jrep -Fw #40.3' \
'яблоко
'
fi

cp1251_locale=`locale -a | grep -iE '1251' -m 1 || true`
if test -n "$cp1251_locale"; then
    (
	unset LC_ALL || true
	LC_CTYPE="$cp1251_locale"
	export LC_CTYPE
	$JREP_CMD -c '\p{IsAlphabetic}+' text5.txt
    ) |
    cmp 'jrep -c and non-standard locale #40.4' \
'2
'
fi

$JREP_CMD -8h -O '============ match ============
${1}' '(?ms:(^Welcome.*?$\n.+?[.]))' text?.txt |
    cmp 'jrep -O #41.1' \
'============ match ============
Welcome to NetBSD!

This system is running a development snapshot of a stable branch of the NetBSD
operating system, which will eventually lead to a new formal release.
============ match ============
Welcome to OpenBSD: The proactively secure Unix-like operating system.

Please use the sendbug(1) utility to report bugs in the system.
'

$JREP_CMD -8h -O '============ match ============
${1n}' '(?ms:(^Welcome.*?$\n.+?[.]))' text?.txt |
    cmp 'jrep -O #41.2' \
'============ match ============
Welcome to NetBSD!\n\nThis system is running a development snapshot of a stable branch of the NetBSD\noperating system, which will eventually lead to a new formal release.
============ match ============
Welcome to OpenBSD: The proactively secure Unix-like operating system.\n\nPlease use the sendbug(1) utility to report bugs in the system.
'

printf '\\\nabba\n\\\n' | $JREP_CMD -8 -O '${0n}' '(?s).+' |
    cmp 'jrep -O #41.2.1' \
'\\\nabba\n\\\n
'

$JREP_CMD -8h -O '============ match ============
${1Ns}' '(?ms:(^Welcome.*?$\n.+?[.]))' text?.txt |
    cmp 'jrep -O #41.3' \
'============ match ============
Welcome to NetBSD! This system is running a development snapshot of a stable branch of the NetBSD operating system, which will eventually lead to a new formal release.
============ match ============
Welcome to OpenBSD: The proactively secure Unix-like operating system. Please use the sendbug(1) utility to report bugs in the system.
'

$JREP_CMD This --include '*.txt' -r . | sort |
    cmp 'jrep -r/-R #42.1' \
'text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:operating system, which will eventually lead to a new formal release.  This
'

$JREP_CMD This --include '*.txt' -R . | sort |
    cmp 'jrep -r/-R #42.2' \
'text1.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1.txt:operating system, which will eventually lead to a new formal release.  This
text1_copy.txt:This system is running a development snapshot of a stable branch of the NetBSD
text1_copy.txt:operating system, which will eventually lead to a new formal release.  This
'

$JREP_CMD -r --exclude-from=excl_patterns 'BSD' . | sort |
    cmp 'jrep --exclude-from #43.1' \
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

$JREP_CMD --exclude-from=excl_patterns 'BSD' *.txt *.sh subdir/* | sort |
    cmp 'jrep --exclude-from #43.2' \
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

$JREP_CMD -O '`${1}` `${2}`' '(BSD)|(zzzz)' text1.txt |
    cmp 'jrep -O #44.1' \
'`BSD` ``
`BSD` ``
`BSD` ``
`BSD` ``
`BSD` ``
'

$JREP_CMD -O '`$1` `$2`' '(BSD)|(zzzz)' text1.txt |
    cmp 'jrep -O #44.2' \
'`BSD` ``
`BSD` ``
`BSD` ``
`BSD` ``
`BSD` ``
'

$JREP_CMD -h -O '$f $0' '\S+BSD\S+' -r --include='*.txt' . | sort |
    cmp 'jrep -O #44.3' \
'subdir/text3.txt FreeBSD!
subdir/text3.txt https://forums.FreeBSD.org/
subdir/text3.txt https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
subdir/text3.txt https://www.FreeBSD.org/faq/
subdir/text3.txt https://www.FreeBSD.org/handbook/
subdir/text3.txt https://www.FreeBSD.org/releases/
subdir/text3.txt https://www.FreeBSD.org/security/
text1.txt NetBSD!
text1.txt http://www.NetBSD.org/support/send-pr.html
text2.txt OpenBSD:
'

$JREP_CMD -h -O '${f} ${0}' '\S+BSD\S+' -r --include='*.txt' . | sort |
    cmp 'jrep -O #44.4' \
'subdir/text3.txt FreeBSD!
subdir/text3.txt https://forums.FreeBSD.org/
subdir/text3.txt https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
subdir/text3.txt https://www.FreeBSD.org/faq/
subdir/text3.txt https://www.FreeBSD.org/handbook/
subdir/text3.txt https://www.FreeBSD.org/releases/
subdir/text3.txt https://www.FreeBSD.org/security/
text1.txt NetBSD!
text1.txt http://www.NetBSD.org/support/send-pr.html
text2.txt OpenBSD:
'

$JREP_CMD -h -O '${fb} ${0}' '\S+BSD\S+' -r --include='*.txt' . | sort |
    cmp 'jrep -O #44.5' \
'text1.txt NetBSD!
text1.txt http://www.NetBSD.org/support/send-pr.html
text2.txt OpenBSD:
text3.txt FreeBSD!
text3.txt https://forums.FreeBSD.org/
text3.txt https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
text3.txt https://www.FreeBSD.org/faq/
text3.txt https://www.FreeBSD.org/handbook/
text3.txt https://www.FreeBSD.org/releases/
text3.txt https://www.FreeBSD.org/security/
'

$JREP_CMD -h -O '${fZ} ${0}' '\S+BSD\S+' -r --include='*.txt' . 2>&1 |
    cmp 'jrep -O #44.6' \
'Unexpected modifier `Z'"'"' in -O argument
'

$JREP_CMD -h -O '${fc},${1c},${2c}' '(\S+)=(.*\S+)$' *.txt |
    cmp 'jrep -O #44.7' \
'text6.txt,varname1,value1
text6.txt,varname2,"100,500.00"
text6.txt,varname3,"String with "" inside"
'

$JREP_CMD -h -O '${fc},${1C},${2C}' '(\S+)=(.*\S+)$' *.txt |
    cmp 'jrep -O #44.8' \
'text6.txt,"varname1","value1"
text6.txt,"varname2","100,500.00"
text6.txt,"varname3","String with "" inside"
'

$JREP_CMD -h -O '${fbe} ${0}' '\S+BSD\S+' -r --include='*.txt' . | sort |
    cmp 'jrep -O #44.9' \
'text1 NetBSD!
text1 http://www.NetBSD.org/support/send-pr.html
text2 OpenBSD:
text3 FreeBSD!
text3 https://forums.FreeBSD.org/
text3 https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
text3 https://www.FreeBSD.org/faq/
text3 https://www.FreeBSD.org/handbook/
text3 https://www.FreeBSD.org/releases/
text3 https://www.FreeBSD.org/security/
'

rm text1_copy.txt

echo `pwd`/text1.txt > excl_pattern2
$JREP_CMD -l --exclude-from=excl_pattern2 'BSD' `pwd`/*.txt | sed 's,.*/,,' |
    cmp 'jrep -O #45.1' \
'patterns.txt
text2.txt
'
rm excl_pattern2

$JREP_CMD -l --exclude=`pwd`/text1.txt 'BSD' `pwd`/*.txt | sed 's,.*/,,' |
    cmp 'jrep -O #45.2' \
'patterns.txt
text2.txt
'

$JREP_CMD --directories=recurse -l --exclude=`pwd`/text1.txt 'BSD' `pwd`/*.txt | sed 's,.*/,,' |
    cmp 'jrep --directories #46.1' \
'patterns.txt
text2.txt
'

$JREP_CMD --directories=skip -l --exclude=`pwd`/text1.txt 'BSD' `pwd` |
    cmp 'jrep --directories #46.2' \
''

{ echo appapp | $JREP_CMD --directories xxx '(app)\1' 2>&1; echo ex=$?; } |
    cmp 'jrep --directories xxx #46.3' \
'Illegal argument `xxx` for option --directories
ex=2
'

{ $JREP_CMD -l --exclude=`pwd`/text1.txt 'BSD' `pwd` 2>&1;
  echo ex=$?; } |
    sed -e 's,/.*/,/path/to/jrep/,' |
    cmp 'jrep #46.4' \
'java.io.FileNotFoundException: /path/to/jrep/tests (Is a directory)
ex=2
'

echo abba | $JREP_CMD -e 'a+' --color always \
	  --marker-start '<b>' --marker-end '</b>' |
    sort |
    cmp 'jrep --marker-{start,end} #47' \
'<b>a</b>bb<b>a</b>
'

$JREP_CMD -rl --exclude-dir '*' '.' . |
    sort |
    cmp 'jrep --exclude-dir #48.1' \
''

$JREP_CMD -rl --exclude-dir '*' '.' `pwd` |
    sort |
    cmp 'jrep --exclude-dir #48.2' \
''

$JREP_CMD -rl --exclude-dir 't' '.' `pwd` | sed "s,`pwd`,.," |
    sort |
    cmp 'jrep --exclude-dir #48.3' \
'./Makefile
./bug_report1.txt
./excl_patterns
./patterns.txt
./subdir/text3.txt
./subdir2/text7.txt
./test.sh
./test_jrep.sh
./text1.txt
./text2.txt
./text3.txt
./text5.txt
./text6.txt
'

$JREP_CMD -rl --include '*.txt' --exclude-dir '*r' '.' . |
    sort |
    cmp 'jrep --exclude-dir #48.4' \
'bug_report1.txt
patterns.txt
subdir2/text7.txt
text1.txt
text2.txt
text3.txt
text5.txt
text6.txt
'

$JREP_CMD -rl --include '*.txt' --exclude-dir='.' '.' . |
    sort |
    cmp 'jrep --exclude-dir #48.5' \
''

$JREP_CMD -rl --include '*.txt' --exclude-dir='*tests' '.' `pwd` |
    sort |
    cmp 'jrep --exclude-dir #48.6' \
''

$JREP_CMD -rl --include '*.txt' --exclude-dir='*tests/sub*' '.' `pwd` |
    sed "s|^$(dirname $(pwd))|.|" |
    sort |
    cmp 'jrep --exclude-dir #48.7' \
'./tests/bug_report1.txt
./tests/patterns.txt
./tests/subdir/text3.txt
./tests/subdir2/text7.txt
./tests/text1.txt
./tests/text2.txt
./tests/text3.txt
./tests/text5.txt
./tests/text6.txt
'

$JREP_CMD -rl --include '*.txt' --exclude-dir='*tests/subdir' '.' `pwd` |
    sed "s|^$(dirname $(pwd))|.|" |
    sort |
    cmp 'jrep --exclude-dir #48.8' \
'./tests/bug_report1.txt
./tests/patterns.txt
./tests/subdir/text3.txt
./tests/subdir2/text7.txt
./tests/text1.txt
./tests/text2.txt
./tests/text3.txt
./tests/text5.txt
./tests/text6.txt
'

$JREP_CMD -rl --include '*.txt' --exclude-dir='*subdir' '.' `pwd` |
    sed "s|^$(dirname $(pwd))|.|" |
    sort |
    cmp 'jrep --exclude-dir #48.9' \
'./tests/bug_report1.txt
./tests/patterns.txt
./tests/subdir2/text7.txt
./tests/text1.txt
./tests/text2.txt
./tests/text3.txt
./tests/text5.txt
./tests/text6.txt
'

$JREP_CMD -rl --include '*.txt' --exclude-dir='*subdir' --exclude-dir='*subdir2' '.' `pwd` |
    sed "s|^$(dirname $(pwd))|.|" |
    sort |
    cmp 'jrep --exclude-dir #48.10' \
'./tests/bug_report1.txt
./tests/patterns.txt
./tests/text1.txt
./tests/text2.txt
./tests/text3.txt
./tests/text5.txt
./tests/text6.txt
'

$JREP_CMD -rl --include '*.txt' --exclude-dir='subdir' --exclude-dir='subdir2' '.' `pwd` |
    sed "s|^$(dirname $(pwd))|.|" |
    sort |
    cmp 'jrep --exclude-dir #48.11' \
'./tests/bug_report1.txt
./tests/patterns.txt
./tests/text1.txt
./tests/text2.txt
./tests/text3.txt
./tests/text5.txt
./tests/text6.txt
'

$JREP_CMD -rl --include '*.txt' --exclude-dir='subdir' --exclude-dir='subdir2' '.' `pwd` |
    sed "s|^$(dirname $(pwd))|.|" |
    sort |
    cmp 'jrep --exclude-dir #48.11' \
'./tests/bug_report1.txt
./tests/patterns.txt
./tests/text1.txt
./tests/text2.txt
./tests/text3.txt
./tests/text5.txt
./tests/text6.txt
'

$JREP_CMD -rl --include '*.txt' --exclude-dir='subdir' --exclude-dir='subdir2' '.' \
     `pwd`/subdir `pwd`/subdir2 |
    sed "s|^$(dirname $(pwd))|.|" |
    sort |
    cmp 'jrep --exclude-dir #48.12' \
''

$JREP_CMD -rl --include '*.txt' --exclude-dir='*/subdir' '.' \
	  `pwd` |
    sed "s|^$(dirname $(pwd))|.|" |
    sort |
    cmp 'jrep --exclude-dir #48.13' \
'./tests/bug_report1.txt
./tests/patterns.txt
./tests/subdir/text3.txt
./tests/subdir2/text7.txt
./tests/text1.txt
./tests/text2.txt
./tests/text3.txt
./tests/text5.txt
./tests/text6.txt
'

$JREP_CMD -r --marker-start '<b>' --marker-end '</b>' \
	  --include '*.txt' --colour=always \
	  -O 'Do you $<like$> $1${<}${2}${>}?' '([^\s.]+)(BSD)' . |
    sort |
    cmp 'jrep -O "$<$>" #49' \
'patterns.txt:Do you <b>like</b> Net<b>BSD</b>?
patterns.txt:Do you <b>like</b> Open<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
subdir/text3.txt:Do you <b>like</b> Free<b>BSD</b>?
text1.txt:Do you <b>like</b> Net<b>BSD</b>?
text1.txt:Do you <b>like</b> Net<b>BSD</b>?
text1.txt:Do you <b>like</b> Net<b>BSD</b>?
text1.txt:Do you <b>like</b> Net<b>BSD</b>?
text1.txt:Do you <b>like</b> Net<b>BSD</b>?
text2.txt:Do you <b>like</b> Open<b>BSD</b>?
text2.txt:Do you <b>like</b> Open<b>BSD</b>?
'

$JREP_CMD -v -e conky -e application bug_report1.txt | tr -d '\015' |
    cmp 'jrep bug report #1.1' \
'i  | cyrconfix                              | package     | 1.0-13.2                                | noarch | (System Packages)                             
i  | kernel-default                         | package     | 4.1.24-5.1.gd60be49                     | x86_64 | (System Packages)                             
i  | kernel-default-devel                   | package     | 4.1.24-5.1.gd60be49                     | x86_64 | (System Packages)                             
i  | kernel-devel                           | package     | 4.1.24-5.1.gd60be49                     | noarch | (System Packages)                             
i  | obs-service-source_validator           | package     | 0.6+git20160222.62c56d3-88.1            | noarch | (System Packages)                             
i  | openSUSE-release-livecd-kde            | package     | 13.2-1.28                               | x86_64 | (System Packages)                             
'

{ printf 'lll\n' | $JREP_CMD -ea -eb -lv; echo ex=$?; } |
    cmp 'jrep bug report #1.2' \
'(standard input)
ex=0
'

{ printf 'lll\n' | $JREP_CMD -ea -eb -cv; echo ex=$?; } |
    cmp 'jrep bug report #1.3' \
'1
ex=0
'

{ printf 'lll\n' | $JREP_CMD -ea -eb -L; echo ex=$?; } |
    cmp 'jrep bug report #1.4' \
'(standard input)
ex=1
'

{ printf 'lll\n' | $JREP_CMD -ea -eb -ov; echo ex=$?; } |
    cmp 'jrep bug report #1.5' \
'ex=0
'


{ printf 'b\n' | $JREP_CMD -ea -eb -lv; echo ex=$?; } |
    cmp 'jrep bug report #1.12' \
'ex=1
'

{ printf 'b\n' | $JREP_CMD -ea -eb -cv; echo ex=$?; } |
    cmp 'jrep bug report #1.13' \
'0
ex=1
'

{ printf 'b\n' | $JREP_CMD -ea -eb -L; echo ex=$?; } |
    cmp 'jrep bug report #1.14' \
'ex=0
'

{ printf 'b\n' | $JREP_CMD -ea -eb -ov; echo ex=$?; } |
    cmp 'jrep bug report #1.15' \
'ex=1
'

echo abba | $JREP_CMD --colour=always \
		      --marker-start '<i>' --marker-end='</i>' 'a*' |
    cmp 'jrep bug report #2' \
'<i>a</i>bb<i>a</i>
'
