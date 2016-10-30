%: Dockerfile.%
	OUT=`sudo docker build -f $^ .`; \
	OUT=`echo $$OUT |awk '{ print $$NF }'`; \
	sudo docker tag $$OUT dubrzr/$@:latest
	sudo docker push dubrzr/$@
