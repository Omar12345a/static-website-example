FROM nginx:1.21.1
LABEL maintainer="omar"
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl && \
    apt-get install -y git

RUN rm -Rf /usr/share/nginx/html/index.html    
RUN git clone https://github.com/Omar12345a/static-website-example.git /usr/share/nginx/html
EXPOSE 80
CMD nginx -g 'daemon off;'
    
