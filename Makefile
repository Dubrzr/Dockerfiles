%: Dockerfile.%
	sudo docker build -f Dockerfile.$@ .
	sudo docker tag $(sudo docker images |head -n 2 |tail -n 1 | awk '{print $3}') dubrzr/$@:latest
	sudo docker push dubrzr/$@
