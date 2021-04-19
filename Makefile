# defaul shell
SHELL = /bin/bash

# Rule "help"
.PHONY: help
.SILENT: help
help:
	echo "Use make [rule]"
	echo "Rules:"
	echo ""
	echo "build 		- build application and generate docker image"
	echo "run-db 		- run mysql database on docker"
	echo "run-app		- run application on docker"
	echo "stop-app	    - stop application"
	echo "stop-db		- stop database"
	echo "rm-app		- stop and delete application"
	echo "rm-db		    - stop and delete database"
	echo ""
	echo "k-setup		- init minikube machine"
	echo "k-deploy-db	- deploy mysql on cluster"
	echo "k-build-app	- build app and create docker image inside minikube"
	echo "k-deploy-app	- deploy app on cluster"
	echo ""
	echo "k-start		- start minikube machine"
	echo "k-all		    - do all the above k- steps"
	echo "k-stop		- stop minikube machine"
	echo "k-delete	    - stop and delete minikube machine"
	echo ""
	echo "check		    - check tools versions"
	echo "help		    - show this message"

# Vai criar a aplicacao de novo e rodar o comando
build:
	mvn clean install; \
	docker build --force-rm -t java-k8s .

# Rode um container com o nome mysql57 e faça o mapeamento de porta, a porta na minha maquina quero 3306 e no container é 3306
# -d para rodar em background e por ultimo a imagem que ele vai utilizar (mysql/mysql-server:5.7)
run-db: stop-db rm-db
	docker run --name mysql57 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_USER=java -e MYSQL_PASSWORD=1234 -e MYSQL_DATABASE=k8s_java -d mysql/mysql-server:5.7

#Rode um container com o nome myapp usando a porta 8080 linkando o banco de dados
run-app: stop-app rm-app
	docker run --name myapp -p 8080:8080 -d -e DATABASE_SERVER_NAME=mysql57 --link mysql57:mysql57 java-k8s:latest

stop-app:
	- docker stop myapp

# Parar o container
stop-db:
	- docker stop mysql57

rm-app:	stop-app
	- docker rm myapp

# Exclui o container
rm-db: stop-db
	- docker rm mysql57

#statar cluster local com 2 cpus e 4Gb de memoria
k-setup:
	minikube -p dev.to start --cpus 2 --memory=4096; \
	minikube -p dev.to addons enable ingress; \
	minikube -p dev.to addons enable metrics-server; \
	kubectl create namespace dev-to

k-deploy-db:
	kubectl apply -f k8s/mysql/;

k-build-app:
	mvn clean install; \
	docker build --force-rm -t java-k8s .

k-build-image:
	eval $$(minikube -p dev.to docker-env) && docker build --force-rm -t java-k8s .;

k-cache-image:
	minikube cache add java-k8s;

k-deploy-app:
	kubectl apply -f k8s/app/;

k-delete-app:
	kubectl delete -f k8s/app/;

k-delete-db:
	kubectl delete -f k8s/mysql/;

k-start:
	minikube -p dev.to start;

k-all: k-setup k-deploy-db k-build-app k-build-image k-deploy-app

k-stop:
	minikube -p dev.to stop;

k-delete:
	minikube -p dev.to stop && minikube -p dev.to delete

check:
	echo "make version " && make --version && echo
	minikube version && echo
	echo "kubectl version" && kubectl version --short --client && echo

