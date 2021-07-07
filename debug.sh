#!/bin/bash

./gradlew clean paperJar

server='https://papermc.io/api/v1/paper/1.17/latest/download'
plugins=(
  'https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar'
)

script=$(basename "$0")
server_folder=".${script%.*}"
mkdir -p "$server_folder"

server_script="server.sh"
server_config="server.sh.conf"

if [ ! -f "$server_folder/$server_script" ]; then
  if [ -f ".server/$server_script" ]; then
    cp ".server/$server_script" "$server_folder/$server_script"
  else
    wget -qc -P "$server_folder" -N 'https://raw.githubusercontent.com/monun/server-script/master/.server/server.sh'
  fi
fi

cd "$server_folder"

if [ ! -f "$server_config" ]; then
    cat << EOF > $server_config
server=$server
debug=true
debug_port=5005
backup=false
restart=false
memory=16
plugins=(
EOF
    for plugin in "${plugins[@]}"
    do
        echo "  \"$plugin\"" >> $server_config
    done
    echo ")" >> $server_config
fi

chmod +x ./$server_script
./$server_script