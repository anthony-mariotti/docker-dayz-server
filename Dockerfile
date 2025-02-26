FROM steamcmd/steamcmd:ubuntu-24

# install deps
RUN set -x \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        lib32gcc-s1 \
        ca-certificates \
        curl \
        pv \
        jq \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# steam cmd and directory conf
ENV USER=dayz
ENV HOME=/steam
ENV SERVER_DIR=/server
ENV MISSION_DIR=${SERVER_DIR}/mpmissions
ENV SCRIPTS_DIR=/scripts

COPY ./server/* /server/
COPY ./scripts/* /scripts/

# filesystem/user
RUN mkdir -p ${SERVER_DIR} ${MISSION_DIR} \
    && groupadd dayz \
    && useradd -m -d ${HOME} -s /bin/bash -g dayz ${USER}

# permissions
RUN chown -R ${USER}:dayz ${SERVER_DIR} ${HOME} ${SCRIPTS_DIR} \
    && chown -R :dayz /usr/bin/steamcmd

WORKDIR ${SERVER_DIR}
USER ${USER}

# update steamcmd & validate user permissions
RUN steamcmd +quit

# game
EXPOSE 2302/udp
EXPOSE 2303/udp
EXPOSE 2304/udp
EXPOSE 2305/udp
# steam
EXPOSE 8766/udp
EXPOSE 27016/udp
# rcon (preferred)
EXPOSE 2310

VOLUME ${SERVER_DIR}

STOPSIGNAL SIGTERM

# reset cmd & define entrypoint
CMD [ "start" ]
ENTRYPOINT [ "/scripts/entrypoint.sh" ]