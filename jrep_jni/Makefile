SRCS =		Utils.c

LIB =		jrep_jni

JAVAH ?=		javah
MKC_REQUIRE_PROGS +=	${JAVAH}

SHLIB_MAJOR =	0
SHLIB_MINOR =	0

arch !=			uname -s
JAVA_INCLUDE_SUBDIR ?=	${arch:tl}

JAVA_INCLUDE ?=		-I${JAVA_HOME}/include \
			-I${JAVA_HOME}/include/${JAVA_INCLUDE_SUBDIR}

CPPFLAGS +=		${JAVA_INCLUDE} -I.

JNI_CLASS =		${SRCDIR_jar}/src/main/java/com/cheusov/Utils.java

.include <mkc.configure.mk>

.if empty(JAVA_HOME) && ${MKCHECKS:U} == yes
.	error "No JAVA_HOME found, JNI building will fail.  Please set JAVA_HOME when using JNI."
.endif

Utils.c: Utils.h

Utils.h: ${JNI_CLASS}
	${JAVAH} -o ${.TARGET} -cp ${JNI_CLASS:C,/com.*,,} \
		${JNI_CLASS:R:C,.*java/,,:S|/|.|g}

CLEANFILES +=	Utils.h

.include <mkc.mk>
