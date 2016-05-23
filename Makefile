PROJECTNAME =	jgrep
SUBPRJ =	jgrep_jni:jar jar:tests scripts:tests doc

test : all-tests test-tests
	@:

.include "Makefile.inc"
.include <mkc.mk>
