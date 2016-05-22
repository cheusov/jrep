test:
	@echo 'running tests...'; \
	unset MAKEFLAGS; \
	set -e; \
	JGREP_JAR=${OBJDIR_jar}/target/jgrep-0.1-jar-with-dependencies.jar; \
	JGREP_JNI_DIR=${OBJDIR_jgrep_jni}; \
	export JGREP_JAR JGREP_JNI_DIR; \
	env PATH="${SRCTOP}:$$PATH" ${SH} ./test.sh

.include <mkc.mk>
