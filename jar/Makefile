FILES =			target/jgrep-0.1-jar-with-dependencies.jar
FILESDIR =		${JARDIR}

MAVEN ?=		mvn
MAVEN_OPTS ?=		
MKC_REQUIRE_PROGS +=	${MAVEN}

JAVA_SRCS =		JgrepHelpFormatter.java Jgrep.java JgrepMatcher.java \
	JgrepOptions.java JgrepPattern.java Utils.java

${FILES}: ${JAVA_SRCS:S|^|src/main/java/com/cheusov/|}
	${PROG.${MAVEN}} ${MAVEN_OPTS} package install assembly:single

clean:
	mvn clean

.include <mkc.mk>
