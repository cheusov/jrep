FILES =			target/jgrep-0.1-jar-with-dependencies.jar
FILESDIR =		${JARDIR}

MAVEN ?=		mvn
MKC_REQUIRE_PROGS +=	${MAVEN}

do-all: ${FILES}
${FILES}: src/main/java/com/cheusov/Jgrep.java
	${PROG.${MAVEN}} package install assembly:single

clean:
	mvn clean

.include <mkc.mk>
