test:
	@echo 'running tests...'; \
	unset MAKEFLAGS; \
	set -e; \
	JREP_JAR=${OBJDIR_jar}/target/jrep-${JAR_VERSION}.jar; \
	JREP_JNI_DIR=${OBJDIR_jrep_jni}; \
	export JREP_JAR JREP_JNI_DIR; \
	cd ${.CURDIR}; \
	env PATH="${SRCTOP}:$$PATH" ${SH} ./test.sh

CLEANFILES = ${.CURDIR}/text1_copy.txt

.include <mkc.mk>
