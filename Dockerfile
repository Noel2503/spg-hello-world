# Use the official Tomcat image with JDK 8
FROM noel135/sample:latest

# Set environment variables
ENV DEPLOY_DIR=/usr/local/tomcat/webapps \
    WAR_NAME=ROOT.war \
    JAVA_OPTS=""

# Argument to pass the WAR file during build
ARG WAR_FILE

# Copy the WAR file to Tomcat's webapps directory
COPY ${WAR_FILE} ${DEPLOY_DIR}/${WAR_NAME}

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat with the option to pass JVM options
ENTRYPOINT ["sh", "-c", "catalina.sh run $JAVA_OPTS"]
