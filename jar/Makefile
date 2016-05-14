FILES =			target/jgrep-0.1-jar-with-dependencies.jar
FILESDIR =		${JARDIR}

MAN =			jgrep.1

do-all: ${FILES}
${FILES}: src/main/java/com/cheusov/Jgrep.java
	${PROG.${MAVEN}} package install assembly:single

.include <mkc.mk>
