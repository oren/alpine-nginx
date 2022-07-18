FROM alpine:latest

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' 

### Install Applications
RUN apk --no-cache update && \
	apk add --no-cache \
	nginx \
	bash
#	openssh
#	certbot

### Remove cache and tmp data
RUN rm -rf \ 
	/var/cache/apk/* \
	/tmp/* \
	/var/tmp/*

RUN mkdir -p /tmp/nginx/client-body
RUN mkdir -p /etc/nginx/sites-enabled

### Volume
VOLUME ["/etc/letsencrypt"]

### Copy Nginx configs
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/.htpasswd /etc/nginx/.htpasswd
COPY website /usr/share/nginx/html
COPY nginx/sites-enabled /etc/nginx/sites-enabled

### Expose ports
EXPOSE 80
EXPOSE 443

#COPY ./docker-entrypoint.sh /
#RUN chmod +x docker-entrypoint.sh

#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["certbot"]

#ENTRYPOINT ["sh", "-c", "nginx"]

CMD ["nginx", "-g", "daemon off;"]
