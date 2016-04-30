test:
	@echo 'running tests...'; \
	unset MAKEFLAGS; \
	set -e; \
	JGREP_JAR=${OBJDIR_jar}/target/jgrep-0.1-jar-with-dependencies.jar; \
	export JGREP_JAR; \
	env PATH="${SRCTOP}:$$PATH" ${SH} ./test.sh

.include <mkc.mk>
