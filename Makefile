PROJECTNAME =	jrep
SUBPRJ =	jrep_jni:jar jar:tests scripts:tests doc

NODEPS =	test-*:test-tests

test : all-tests test-tests
	@:

.include "Makefile.inc"
.include <mkc.mk>
