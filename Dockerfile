# Build stage
FROM maven:3.8.3-jdk-11 AS build
WORKDIR /home/app
COPY src ./src
COPY pom.xml .
RUN mvn -DskipTests -f ./pom.xml clean package


# SonarQube Cloud analyses
FROM build AS sonarscan
WORKDIR /home/app
RUN mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
-Dsonar.projectKey=hello-world-maven \
-Dsonar.organization=corporation-of-good \
-Dsonar.host.url=https://sonarcloud.io \
-Dsonar.login=2e6277be935218a1aeddda81060d899a4fd20567 

# Run unit tests
FROM sonarscan as test
WORKDIR /home/app
RUN mvn test -f ./pom.xml


FROM openjdk:11.0-oraclelinux8
COPY --from=build /home/app/target/*-SNAPSHOT.jar /usr/app/demo-0.0.1-SNAPSHOT.jar  
EXPOSE 8080  
CMD ["java","-jar","/usr/app/demo-0.0.1-SNAPSHOT.jar"]  

# Deploy stage
# FROM tomcat:9-jre11-openjdk-slim as runapp
# COPY --from=build /home/app/target/*-SNAPSHOT.war /usr/local/tomcat/webapps
# CMD ["catalina.sh", "run"]
# EXPOSE 8080
