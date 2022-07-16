FROM alpine:latest

RUN apk add --update nginx && rm -rf /var/cache/apk/*
RUN mkdir -p /tmp/nginx/client-body
RUN apk add --no-cache bash
RUN apk add --no-cache openssh

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/.htpasswd /etc/nginx/.htpasswd
COPY website /usr/share/nginx/html

RUN mkdir -p /etc/nginx/sites-enabled
COPY nginx/sites-enabled /etc/nginx/sites-enabled

CMD ["nginx", "-g", "daemon off;"]
