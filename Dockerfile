# Arquivo para kogar aplicacao no docker

FROM openjdk:15-alpine

# criar um diretorio no container
RUN mkdir /usr/myapp

# Copiar para o container
COPY target/java-kubernetes.jar /usr/myapp/app.jar
WORKDIR /usr/myapp

# Onde o servico vai rodar
EXPOSE 8080

ENTRYPOINT [ "sh", "-c", "java --enable-preview $JAVA_OPTS -jar app.jar" ]
