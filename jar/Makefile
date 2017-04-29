FILES =			target/jrep-${JAR_VERSION}.jar
FILESDIR =		${JARDIR}

MAVEN ?=		mvn
MAVEN_OPTS ?=		
MKC_REQUIRE_PROGS +=	${MAVEN}

JAVA_SRCS !=		echo src/main/java/com/cheusov/*.java

MAVEN_CMD =	${PROG.${MAVEN}:Umvn} -f${.CURDIR}/pom.xml \
   -DbuildDir=${.OBJDIR}/target ${MAVEN_OPTS}

.include <mkc.init.mk> # for assigning value to variable JAR_VERSION

${FILES}: ${JAVA_SRCS}
	${MAVEN_CMD} package install

clean:
	${MAVEN_CMD} clean

.include <mkc.mk>
