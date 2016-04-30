FILES =			target/jgrep-0.1-jar-with-dependencies.jar
FILESDIR =		${JARDIR}

do-all: ${FILES}
${FILES}:
	${PROG.${MAVEN}} package install assembly:single

.include <mkc.mk>
