PROJECTNAME =	jrep
SUBPRJ =	jrep_jni:jar jar:tests scripts:tests doc

test : all-tests test-tests
	@:

.include "Makefile.inc"
.include <mkc.mk>
