#!/bin/bash

set -e

STEAM_USER=${STEAM_USER:-}
STEAM_PASS=${STEAM_PASS:-}
STEAM_CODE=${STEAM_CODE:-}
STEAM_PASS_FILE=${STEAM_PASS_FILE:-}
DZ_MISSION=${DZ_MISSION:-dayzOffline.chernarusplus}

DZ_CONFIG=serverDZ.current.cfg
DZ_TMPL_CONFIG=serverDZ.tmpl.cfg
DZ_STG_CONFIG=serverDZ.stg.cfg

if [ -z "$STEAM_USER" ]; then
    echo -e "\n\n[ERROR] Missing required STEAM_USER environment variable"
    exit 78
fi

if [ -z "$STEAM_PASS" ] && [ -z "$STEAM_PASS_FILE" ]; then
    echo -e "\n\n[ERROR] Missing required STEAM_PASS or STEAM_PASS_FILE environment variable"
    exit 78
fi

function update() {
    echo "Updating DayZ Server"

    if [ -n "$STEAM_PASS_FILE" ]; then
        STEAM_PASS=$(cat $STEAM_PASS_FILE)
    fi

    steamcmd \
        +force_install_dir $SERVER_DIR \
        +login "$STEAM_USER" "$STEAM_PASS" "$STEAM_CODE" \
        +app_update 223350 \
        $STEAM_EXTRA_ARGS \
        +quit

    if [ ! -d "${MISSION_DIR}/${DZ_MISSION}" ] || [ -z "$(ls -A ${MISSION_DIR}/${DZ_MISSION})" ]; then
        echo -e "\n[WARNING] The Steam account used to install this server does not own the DayZ game!"
        echo -e "\t${DZ_MISSION} mission files will have to be MANUALLY updated in the future if they update!"
        echo -e "\tDownloading and installing ${DZ_MISSION} mission files...\n"

        if [ ! -d "${MISSION_DIR}" ]; then
            mkdir -p ${MISSION_DIR}
        fi

        cd ${MISSION_DIR}

        LATEST_JSON=$(curl -s "https://api.github.com/repos/BohemiaInteractive/DayZ-Central-Economy/releases/latest")
        DOWNLOAD_URL=$(echo ${LATEST_JSON} | jq -r .tarball_url)

        curl -Lso missions.tar.gz ${DOWNLOAD_URL}

        if [ ! -f missions.tar.gz ]; then
            echo -e "\n\n[ERROR] Failed to download vanilla mission files!"
            exit 1
        fi

        echo -e "Extracing ${DZ_MISSION} mission files..."
        tar -xzvf missions.tar.gz --strip-components=1 --wildcards "*/${DZ_MISSION}/*"
        rm -f missions.tar.gz
    fi
}

function configure() {
    cd $SERVER_DIR
    # TODO: Currently the volume mount directly to the file is root:root permission and cannot override the permissions.
    if grep -q "serverDZ.cfg" /proc/mounts; then
        echo -e "\n[WARNING] serverDZ.cfg was mounted to the container."
        echo -e "\tEnvironment variables with DZ_* will no longer configure the server.\n"

        cp serverDZ.cfg $DZ_STG_CONFIG
        return 0
    fi

    local SERVER_NAME=${DZ_NAME:-}
    local SERVER_PASSWORD=${DZ_PASSWORD:-}
    local SERVER_ADMIN_PASSWORD=${DZ_PASSWORD_ADMIN:-}

    if [ -n "$DZ_PASSWORD_FILE" ]; then
        SERVER_PASSWORD=$(cat $DZ_PASSWORD_FILE)
    fi

    if [ -n "$DZ_PASSWORD_ADMIN_FILE" ]; then
        SERVER_ADMIN_PASSWORD=$(cat $DZ_PASSWORD_ADMIN_FILE)
    fi

    sed -e "s/{{SERVER_NAME}}/${SERVER_NAME//&/\\&}/g" \
        -e "s/{{SERVER_PASSWORD}}/${SERVER_PASSWORD//&/\\&}/g" \
        -e "s/{{SERVER_ADMIN_PASSWORD}}/${SERVER_ADMIN_PASSWORD//&/\\&}/g" \
        -e "s/{{ENABLE_WHITELIST}}/${DZ_ENABLE_WHITELIST:-0}/g" \
        -e "s/{{MAX_PLAYERS}}/${DZ_MAX_PLAYERS:-60}/g" \
        -e "s/{{FORCE_SAME_BUILD}}/${DZ_FORCE_SAME_BUILD:-1}/g" \
        -e "s/{{DISABLE_VOICE}}/${DZ_DISABLE_VOICE:-0}/g" \
        -e "s/{{VOICE_QUALITY}}/${DZ_VOICE_QUALITY:-20}/g" \
        -e "s/{{DISABLE_THIRD_PERSON}}/${DZ_DISABLE_THIRD_PERSON:-0}/g" \
        -e "s/{{DISABLE_CROSSHAIR}}/${DZ_DISABLE_CROSSHAIR:-0}/g" \
        -e "s/{{DISABLE_PERSONAL_LIGHT}}/${DZ_DISABLE_PERSONAL_LIGHT:-0}/g" \
        -e "s/{{LIGHTING_TYPE}}/${DZ_DARKER_NIGHT:-0}/g" \
        -e "s/{{ACCELERATION_TIME}}/${DZ_ACCELERATION_TIME:-12}/g" \
        -e "s/{{NIGHT_ACCELERATION_TIME}}/${DZ_NIGHT_ACCELERATION_TIME:-1}/g" \
        -e "s/{{PERSISTENT_TIME}}/${DZ_PERSISTENT_TIME:-0}/g" \
        -e "s/{{LOGIN_QUEUE_PLAYERS}}/${DZ_LOGIN_QUEUE_CONCURRENT:-5}/g" \
        -e "s/{{LOGIN_QUEUE_MAX}}/${DZ_LOGIN_QUEUE_MAX:-500}/g" \
        -e "s/{{INSTANCE_ID}}/${DZ_INSTANCE_ID:-1}/g" \
        -e "s/{{STORAGE_AUTOFIX}}/${DZ_STORAGE_AUTOFIX:-1}/g" \
        -e "s/{{SERVER_MISSION}}/${DZ_MISSION//&/\\&}/g" \
        $DZ_TMPL_CONFIG > $DZ_STG_CONFIG


    # if grep -q "{{.*}}" serverDZ.cfg; then
    #     echo "Found Template in File"
    # fi
}

# function getMap() {
#     mkdir -p /tmp/mpmissions
    
#     curl -sL https://github.com/BohemiaInteractive/DayZ-Central-Economy/archive/refs/tags/DZ_126.tar.gz \
#         | pv --name "Downloading" >> /tmp/mpmissions/download.tar.gz

#     pv --name "Extracting" /tmp/mpmissions/download.tar.gz \
#         | tar --strip-components=1 -xz -C /tmp/mpmissions

#     mv /tmp/mpmissions/${DZ_MISSION} ${MISSION_DIR}
#     rm -rf /tmp/mpmissions
# }

function start() {
    echo "Starting DayZ Server"
    cd ${SERVER_DIR}
    
    cp $DZ_STG_CONFIG $DZ_CONFIG

    ./DayZServer \
        -config=${DZ_CONFIG} \
        -port=2302 \
        -BEpath=battleye \
        -profiles=profiles \
        -dologs \
        -adminlog \
        -netlog \
        -freezecheck \
        ${DZ_EXTRA_ARGS:-}
}

case "$1" in
start)
    update
    configure
    start
    ;;
update)
    update
    configure
    ;;
*)
    exec "$@"
    ;;
esac
