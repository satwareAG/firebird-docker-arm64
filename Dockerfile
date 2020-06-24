FROM debian:stretch
LABEL maintainer="wegener@satware.com"

ENV PREFIX=/usr/local/firebird
ENV VOLUME=/firebird
ENV DEBIAN_FRONTEND noninteractive
ENV FBURL=https://github.com/FirebirdSQL/firebird/releases/download/R2_5_9/Firebird-2.5.9.27139-0.tar.bz2
ENV DBPATH=/firebird/data

COPY build.sh ./build.sh

RUN chmod +x ./build.sh && \
    sync && \
    ./build.sh && \
    rm -f ./build.sh

VOLUME ["/firebird"]

EXPOSE 3050/tcp

COPY docker-entrypoint.sh ${PREFIX}/docker-entrypoint.sh
RUN chmod +x ${PREFIX}/docker-entrypoint.sh

COPY docker-healthcheck.sh ${PREFIX}/docker-healthcheck.sh
RUN chmod +x ${PREFIX}/docker-healthcheck.sh
HEALTHCHECK CMD ${PREFIX}/docker-healthcheck.sh || exit 1

ENTRYPOINT ["/usr/local/firebird/docker-entrypoint.sh"]

CMD ["/usr/local/firebird/bin/fbguard"]
