FROM alpine:3.1
RUN apk add --update nginx && rm -rf /var/cache/apk/*

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
