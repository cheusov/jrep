FILES =			target/jrep-${JAR_VERSION}.jar
FILESDIR =		${JARDIR}

MAVEN ?=		mvn
MAVEN_OPTS ?=		
MKC_REQUIRE_PROGS +=	${MAVEN}

JAVA_SRCS =		JrepHelpFormatter.java Jrep.java \
	JrepJdkMatcher.java JrepRe2jMatcher.java \
	JrepOptions.java JrepPattern.java Utils.java

MAVEN_CMD =	${PROG.${MAVEN}:Umvn} -f${.CURDIR}/pom.xml \
   -DbuildDir=${.OBJDIR}/target ${MAVEN_OPTS}

.include <mkc.init.mk> # for assigning value to variable JAR_VERSION

${FILES}: ${JAVA_SRCS:S|^|src/main/java/com/cheusov/|}
	${MAVEN_CMD} package install

clean:
	${MAVEN_CMD} clean

.include <mkc.mk>
