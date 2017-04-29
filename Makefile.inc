VERSION =	1.1.0

.ifdef SRCTOP
JAR_VERSION !=	${SRCTOP}/helpers/get_jar_version ${SRCTOP}/jar/pom.xml
.endif

JARDIR ?=	${LIBDIR}/jrep
DOCDIR ?=	${DATADIR}/jrep

INTEXTS_REPLS +=	jar_version ${JAR_VERSION}
EXPORT_VARNAMES +=	JAR_VERSION # for tests/Makefile
