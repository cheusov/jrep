unset JGREP_COLOR
unset GREP_COLOR

GREP_CMD='jgrep'

$GREP_CMD OpenBSD text2.txt |
    cmp 'jgrep #1' \
'OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
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

$GREP_CMD -V |
    cmp 'jgrep - #21.1' \
'jgrep-0.1
'

$GREP_CMD --version |
    cmp 'jgrep - #21.2' \
'jgrep-0.1
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

$GREP_CMD --regexp OpenBSD text2.txt |
    cmp 'jgrep -e #6' \
'OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012
Welcome to OpenBSD: The proactively secure Unix-like operating system.
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
    cmp 'jgrep -8io #12' \
'text1.txt:NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!
text2.txt:OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.
'

$GREP_CMD -8iohEGP '(?m:^(openbsd|netbsd).*\n\n.*$)' text1.txt text2.txt |
    cmp 'jgrep -8ioh #13' \
'NetBSD 6.1_STABLE (GENERIC) #2: Fri Oct 24 07:00:58 FET 2014

Welcome to NetBSD!
OpenBSD 5.2-beta (GENERIC) #62: Wed Jul 11 14:45:11 EDT 2012

Welcome to OpenBSD: The proactively secure Unix-like operating system.
'
