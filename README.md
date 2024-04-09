# docker-lab-5-scratch-nodejs-nginx
Utilizing multi-stage builds with scratch and nginx images for hosting a Node.js application on an nginx server.

## Table of Contents

- [Requirements](#requirements)
- [Dockerfile](#dockerfile)
- [Image Building](#image-building)
- [Container Setup and Running](#container-setup-and-running)

## Requirements

For Linux and Windows systems Docker or Docker Desktop installed and running.

For Windows systems WSL installed.

## Dockerfile

Dockerfile used to build this image:

```dockerfile
# Stage 1
FROM scratch AS base

# for x86_64 uncomment the following line
ADD alpine-minirootfs-3.19.1-x86_64.tar /
# for aarch64 uncomment the following line
# ADD alpine-minirootfs-3.19.1-aarch64 /

ARG VERSION=1.0.0

ENV APP_VERSION=$VERSION

WORKDIR /usr/app

RUN apk update && \
    apk add --no-cache nodejs
    
COPY ./index.js ./

# comment the following 2 lines when building image (use it only for testing stage 1 - comment stage 2 in this case)
# EXPOSE 3000
# CMD ["node", "index.js"]

# Stage 2
FROM nginx

RUN apt-get update && \ 
    apt-get install -y nodejs supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=base /usr/app /usr/share/nginx/html

COPY ./supervisor_conf.txt /etc/supervisor/conf.d/supervisord.conf

COPY ./nginx_conf.txt /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -fs http://localhost/ || exit 1

ARG VERSION=1.0.0

ENV APP_VERSION=$VERSION

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

## Image Building

Example for Windows:

Download files and open console. Change directory to the location of the downloaded files.

```cmd
cd C:\location\of\downloaded\files\
```

If you need to edit any configuration files or make any changes, now is the time.

Save all changes if files were edited, then run the command to build a new image with Dockerfile named scratch-node-nginx-mix:

```cmd
docker build --build-arg VERSION=1.0 -t scratch-node-nginx-mix .
```
Example result from this command:

![Image Build](screenshots/image_build.jpg)

## Container Setup and Running

To create a container with the scratch-node-nginx-mix image, specify the modes it will run in (-d in this case), ports (-p portOnYourHostMachine:PortOnApacheServer(80 default for this image)), the name of the container (--name nginx-server in this case) and any additional options that will be needed. The example command below demonstrates how to create a container with the scratch-node-nginx-mix image.

```cmd
docker run -d -p 3000:80 --name nginx-server scratch-node-nginx-mix
```

Afterward, the healthcheck status should be verified to ensure that the server is functioning properly. Example command:

```cmd
docker ps --filter name=nginx-server
```

An example of the result from this command:

![Healthy](screenshots/healthy.jpg)

In the STATUS column, "Up" and "healthy" statuses are visible, indicating that the container is working properly.

After that, it is possible to access the Nginx server working on the running container through port 3000 in this case. Just type localhost:3000 in the browser search bar.

![Custom Server Home Page](screenshots/custom_server_home_page.jpg)

If stopping a running container:

```cmd
docker stop nginx-server
```

If starting a container that is not currently running but was previously created:

```cmd
docker start nginx-server
```

