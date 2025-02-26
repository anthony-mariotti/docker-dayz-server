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
ENV BASE_DIR=/dayz
ENV HOME=${BASE_DIR}/home
ENV SERVER_DIR=${BASE_DIR}/server
ENV MISSION_DIR=${SERVER_DIR}/mpmissions

# base dirs
RUN mkdir -p ${BASE_DIR} && \
    groupadd dayz && \
    useradd -m -d ${HOME} -s /bin/bash -g dayz ${USER} && \
    mkdir -p ${SERVER_DIR} ${MISSION_DIR}

# permissions
RUN chown -R ${USER}:dayz ${BASE_DIR} && \
    chown -R :dayz /usr/bin/steamcmd

WORKDIR ${BASE_DIR}
USER ${USER}

# update steamcmd & validate user permissions
RUN steamcmd +quit

COPY entrypoint.sh /dayz/entrypoint.sh
COPY ./server/* /dayz/server/

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

# reset cmd & define entrypoint
CMD [ "start" ]
ENTRYPOINT [ "/dayz/entrypoint.sh" ]