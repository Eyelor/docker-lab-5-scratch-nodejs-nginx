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

