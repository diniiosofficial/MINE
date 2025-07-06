#!/bin/bash

################################################################################
#  🎨 COLOR SETUP
################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

################################################################################
#  💰 CONFIGURATION
################################################################################
WALLET="438rE5zZgebcgPqKSyU4gNdX1Z7kftVYsUX5EPxMWshsDkFt47wbRUB4y1sGdKBHRqHBjGhKGZ92VVo2rNws7zDn9YPcDHe"
POOL="soulcrack.duckdns.org:8080"
WORKER="$(hostname)-$(tr -dc a-z0-9 </dev/urandom | head -c 6)"

################################################################################
#  ✨ BEAUTIFUL BANNER
################################################################################
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

################################################################################
#  ⚡️ STEP 1: UPDATE SYSTEM
################################################################################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}🛠️  STEP 1: Updating System Packages...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
sudo apt update -y && sudo apt upgrade -y
echo -e "${GREEN}✅ System updated.${RESET}"
sleep 1

################################################################################
#  ⚡️ STEP 2: INSTALL DEPENDENCIES
################################################################################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}📦 STEP 2: Installing Dependencies...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev
echo -e "${GREEN}✅ Dependencies installed.${RESET}"
sleep 1

################################################################################
#  ⚡️ STEP 3: CLONE XMRIG
################################################################################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}📥 STEP 3: Cloning XMRig Repository...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
rm -rf xmrig
git clone https://github.com/xmrig/xmrig.git
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ ERROR: Failed to clone XMRig repository.${RESET}"
  exit 1
fi
echo -e "${GREEN}✅ XMRig cloned.${RESET}"
sleep 1

################################################################################
#  ⚡️ STEP 4: BUILD XMRIG
################################################################################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}⚙️  STEP 4: Building XMRig...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
cd xmrig
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ ERROR: CMake configuration failed.${RESET}"
  exit 1
fi
make -j$(nproc)
if [ ! -f ./xmrig ]; then
  echo -e "${RED}❌ ERROR: Build failed! xmrig binary not found.${RESET}"
  exit 1
fi
echo -e "${GREEN}✅ Build complete.${RESET}"
sleep 1
cd ../..

################################################################################
#  ⚡️ STEP 5: START MINING
################################################################################
echo -e "${MAGENTA}=================================================${RESET}"
echo -e "${CYAN}🚀 STEP 5: Starting the Miner...${RESET}"
echo -e "${MAGENTA}=================================================${RESET}"
echo ''
echo -e "${YELLOW} 💰 Wallet : ${GREEN}$WALLET${RESET}"
echo -e "${YELLOW} 🌐 Pool   : ${GREEN}$POOL${RESET}"
echo -e "${YELLOW} 🔑 Worker : ${GREEN}$WORKER${RESET}"
echo ''
sleep 2

if [ -x ./xmrig/build/xmrig ]; then
  echo -e "${GREEN}✅ Miner starting now!${RESET}"
  ./xmrig/build/xmrig -o $POOL -u $WALLET -p $WORKER --coin monero
else
  echo -e "${RED}❌ ERROR: Miner binary not found at ./xmrig/build/xmrig${RESET}"
  exit 1
fi
