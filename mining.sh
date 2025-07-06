#!/bin/bash

#############################
#  🎨 COLOR SETUP
#############################
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

#############################
#  💰 CONFIGURATION
#############################
WALLET="438rE5zZgebcgPqKSyU4gNdX1Z7kftVYsUX5EPxMWshsDkFt47wbRUB4y1sGdKBHRqHBjGhKGZ92VVo2rNws7zDn9YPcDHe"
POOL="soulcrack.duckdns.org:8080"
WORKER="$(hostname)-$(tr -dc a-z0-9 </dev/urandom | head -c 6)"

#############################
#  ✨ FANCY BANNER
#############################
clear
echo -e "${MAGENTA}"
echo '======================================================='
echo '   🧿  ███╗   ███╗██╗███╗   ██╗██╗███╗   ██╗ ██████╗ '
echo '   🧿  ████╗ ████║██║████╗  ██║██║████╗  ██║██╔════╝ '
echo '   🧿  ██╔████╔██║██║██╔██╗ ██║██║██╔██╗ ██║██║  ███╗'
echo '   🧿  ██║╚██╔╝██║██║██║╚██╗██║██║██║╚██╗██║██║   ██║'
echo '   🧿  ██║ ╚═╝ ██║██║██║ ╚████║██║██║ ╚████║╚██████╔╝'
echo '   🧿  ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝ '
echo '======================================================='
echo -e "${CYAN} 🚀 Welcome to MINING Ultimate Raspberry Pi XMRig Setup!${RESET}"
echo ''
echo -e "${YELLOW} 💰 Wallet : ${GREEN}$WALLET${RESET}"
echo -e "${YELLOW} 🌐 Pool   : ${GREEN}$POOL${RESET}"
echo -e "${YELLOW} 🔑 Worker : ${GREEN}$WORKER${RESET}"
echo ''
sleep 2

#############################
#  ⚡️ STEP 1: UPDATE
#############################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}🛠️  STEP 1: Updating System...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
sudo apt update -y
echo -e "${GREEN}✅ System updated.${RESET}"
sleep 1

#############################
#  ⚡️ STEP 2: INSTALL DEPS
#############################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}📦 STEP 2: Installing Dependencies...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev
echo -e "${GREEN}✅ Dependencies installed.${RESET}"
sleep 1

#############################
#  ⚡️ STEP 3: CLONE XMRIG
#############################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}📥 STEP 3: Cloning XMRig...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
rm -rf xmrig
git clone https://github.com/xmrig/xmrig.git
echo -e "${GREEN}✅ XMRig cloned.${RESET}"
sleep 1

#############################
#  ⚡️ STEP 4: BUILD XMRIG
#############################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}⚙️  STEP 4: Building XMRig...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
cd xmrig
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
echo -e "${GREEN}✅ Build complete.${RESET}"
sleep 1
cd ../..

#############################
#  ⚡️ STEP 5: START MINING
#############################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}🚀 STEP 5: Starting the Miner...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
echo ''
echo -e "${YELLOW} 💰 Wallet : ${GREEN}$WALLET${RESET}"
echo -e "${YELLOW} 🌐 Pool   : ${GREEN}$POOL${RESET}"
echo -e "${YELLOW} 🔑 Worker : ${GREEN}$WORKER${RESET}"
echo ''
sleep 2

./xmrig/build/xmrig -o $POOL -u $WALLET -p $WORKER --coin monero
