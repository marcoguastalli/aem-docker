# v19
nginx https alpine with index.html rendering the Bitcoin Block Count

### build
- `cd ~/dev/repository/git/aem-docker/src/nginx/src/v19`
- `docker build --no-cache -t nginx:v19 .`

### run
- `docker run -d --rm --name nginx.v19 -p 443:443 nginx:v19`

### access the image as root
- `docker run -it nginx:v19 /bin/sh`
- `cat /etc/alpine-release`

### access the container as root
- `docker container ls`
- `docker exec -u root -it CONTAINER_ID /bin/sh`
- `tail -f -n 1000 /var/log/nginx/error.log`
- `tail -f -n 1000 /var/log/nginx/access.log`

# play
- `curl -kI https://localhost`
