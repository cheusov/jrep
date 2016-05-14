PROJECTNAME =	jgrep
SUBPRJ =	jar:tests scripts:tests doc

test : all-tests test-tests
	@:

.include <mkc.mk>
