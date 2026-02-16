# nginx
Run a container with Nginx

### inspiring links
- https://nginx.org/en/docs/http/configuring_https_servers.html
- https://github.com/ikknd/docker-study

### images
- https://hub.docker.com/_/nginx
- https://hub.docker.com/_/nginx/tags?page=&page_size=&ordering=&name=alpine

### run nginx in docker
- `docker run --detach --publish=9090:80 --name=webserver nginx:stable-alpine-slim`
- `curl http://localhost:9090`

### generate nginx certificates
- `mkdir -p ~/Downloads/nginx-certs`
- `docker run --detach --publish=9090:80 --publish=9443:443 --name=webserver -v~/Downloads/nginx-certs:/certs nginx:stable`
- `docker container ls`
- `docker exec -u root -it webserver sh -c "
   openssl req -x509 -nodes -newkey rsa:4096 \
   -keyout /certs/nginx-selfsigned.key \
   -out /certs/nginx-selfsigned.crt \
   -subj '/CN=localhost' \
   -days 3650"`
- 