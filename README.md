# aem-docker
Adobe AEM in a docker container

### Build
- `cd ~/dev/repository/git/aem-docker/src/v1`
- `docker-compose build author publish`

### Run
- `docker-compose up -d`
- `docker-compose up -d author publish`
- `docker-compose up -d --force-recreate dispatcher`
- `docker-compose restart dispatcher`
- `docker-compose start`
- `docker-compose stop`
- `docker-compose ps`

### Play
- http://localhost:8080
- curl -I http://localhost:8080
