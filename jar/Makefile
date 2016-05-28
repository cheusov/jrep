FILES =			target/jrep-0.1-jar-with-dependencies.jar
FILESDIR =		${JARDIR}

MAVEN ?=		mvn
MAVEN_OPTS ?=		
MKC_REQUIRE_PROGS +=	${MAVEN}

JAVA_SRCS =		JrepHelpFormatter.java Jrep.java JrepMatcher.java \
	JrepOptions.java JrepPattern.java Utils.java

${FILES}: ${JAVA_SRCS:S|^|src/main/java/com/cheusov/|}
	${PROG.${MAVEN}} ${MAVEN_OPTS} package install assembly:single

clean:
	mvn clean

.include <mkc.mk>
