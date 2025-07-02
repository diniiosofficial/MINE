#!/bin/bash

########################
#  💰 CONFIG
########################
WALLET="438rE5zZgebcgPqKSyU4gNdX1Z7kftVYsUX5EPxMWshsDkFt47wbRUB4y1sGdKBHRqHBjGhKGZ92VVo2rNws7zDn9YPcDHe"
POOL="soulcrack.duckdns.org:8080"
WORKER="$(hostname)-$(tr -dc a-z0-9 </dev/urandom | head -c 6)"

########################
#  🖥️ INFO BANNER
########################
clear
echo "==========================================="
echo "   🚀 Raspberry Pi XMRig Miner Setup"
echo "==========================================="
echo "💰 Wallet : $WALLET"
echo "🌐 Pool   : $POOL"
echo "🔑 Worker : $WORKER"
echo "💻 Device : $(uname -m)"
echo "==========================================="
echo ""

sleep 2

########################
#  🔄 UPDATE & INSTALL
########################
echo "📦 Updating system and installing dependencies..."
sudo apt update -y
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

########################
#  📥 CLONE & BUILD XMRig
########################
echo "📥 Cloning XMRig..."
rm -rf xmrig
git clone https://github.com/xmrig/xmrig.git

echo "⚙️ Building XMRig..."
cd xmrig
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

########################
#  🚀 START MINING
########################
echo ""
echo "==========================================="
echo "✅ Setup complete. Starting miner now..."
echo "==========================================="
echo ""
sleep 2

./xmrig -o $POOL -u $WALLET -p $WORKER --coin monero
#!/bin/bash

############################
#  💰 CONFIGURATION
############################
WALLET="438rE5zZgebcgPqKSyU4gNdX1Z7kftVYsUX5EPxMWshsDkFt47wbRUB4y1sGdKBHRqHBjGhKGZ92VVo2rNws7zDn9YPcDHe"
POOL="soulcrack.duckdns.org:8080"
WORKER="$(hostname)-$(tr -dc a-z0-9 </dev/urandom | head -c 6)"

API_PORT=16000
TELEGRAM_BOT_TOKEN="8097013442:AAEtxyvS11jAnExU07l3vsesD9oG7ujTTmU"
CHAT_ID="5707956654"

# Assumed exchange rates (update as needed)
XMR_USD=120
USD_INR=83

# Interval between Telegram updates (seconds)
INTERVAL=300

############################
#  ✅ BANNER
############################
clear
echo "==========================================="
echo "   🚀 Kali Linux Raspberry Pi Monero Miner"
echo "==========================================="
echo "💰 Wallet : $WALLET"
echo "🌐 Pool   : $POOL"
echo "🔑 Worker : $WORKER"
echo "🌐 API    : 127.0.0.1:$API_PORT"
echo "==========================================="
echo "⚠️  Tip: Use 64-bit Kali for best mining performance!"
echo "==========================================="
sleep 2

############################
#  🔄 UPDATE & INSTALL
############################
echo "📦 Updating system and installing dependencies..."
sudo apt update -y
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev jq curl

############################
#  📥 CLONE & BUILD XMRIG
############################
echo "📥 Cloning XMRig..."
rm -rf xmrig
git clone https://github.com/xmrig/xmrig.git

echo "⚙️ Building XMRig..."
cd xmrig
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_HWLOC=OFF
make -j$(nproc)
cd ../..

############################
#  🚀 START XMRIG IN BACKGROUND
############################
echo ""
echo "==========================================="
echo "✅ Starting XMRig Miner in background..."
echo "==========================================="
./xmrig/build/xmrig \
  -o $POOL \
  -u $WALLET \
  -p $WORKER \
  --coin monero \
  --randomx-no-huge-pages \
  -t 3 \
  --api-port $API_PORT > xmrig.log 2>&1 &

MINER_PID=$!
echo "🟢 XMRig started with PID $MINER_PID"
sleep 5

############################
#  📤 SEND STARTUP TELEGRAM ALERT
############################
echo "📨 Sending startup Telegram message..."
STARTUP_MESSAGE="✅ *Raspberry Pi XMRig Miner Started* 🚀
💰 Wallet: \`$WALLET\`
🌐 Pool: \`$POOL\`
⚡ Worker: \`$WORKER\`
🟢 Mining has begun successfully!"
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$STARTUP_MESSAGE" \
    -d parse_mode="Markdown"

############################
#  🔁 MONITORING LOOP
############################
echo ""
echo "==========================================="
echo "📡 Starting monitoring loop for Telegram alerts..."
echo "==========================================="

while true
do
    ############################
    #  1️⃣ GET XMRIG STATS
    ############################
    RESPONSE=$(curl -s "http://127.0.0.1:$API_PORT/2/summary")
    if [ -z "$RESPONSE" ]; then
        HASHRATE="0"
        ACCEPTED="0"
        REJECTED="0"
    else
        HASHRATE=$(echo "$RESPONSE" | jq '.hashrate.total[0]')
        ACCEPTED=$(echo "$RESPONSE" | jq '.results.total')
        REJECTED=$(echo "$RESPONSE" | jq '.results.rejected')
    fi

    ############################
    #  2️⃣ CALCULATE EARNINGS
    ############################
    XMR_PER_DAY=$(echo "$HASHRATE * 0.0000015" | bc -l)
    USD_PER_DAY=$(echo "$XMR_PER_DAY * $XMR_USD" | bc -l)
    INR_PER_DAY=$(echo "$USD_PER_DAY * $USD_INR" | bc -l)

    ############################
    #  3️⃣ READ TEMPERATURE
    ############################
    if command -v vcgencmd &> /dev/null; then
        TEMP=$(vcgencmd measure_temp | grep -oP '[0-9]+\.[0-9]+')
    elif [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        RAW_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP=$(echo "scale=1; $RAW_TEMP / 1000" | bc)
    else
        TEMP="N/A"
    fi

    ############################
    #  4️⃣ FORMAT TELEGRAM MESSAGE
    ############################
    MSG="💰 *XMRig Mining Status* 🚀

⚡ *Hashrate:* \`${HASHRATE} H/s\`
✅ *Accepted Shares:* \`${ACCEPTED}\`
❌ *Rejected Shares:* \`${REJECTED}\`
🌡️ *CPU Temp:* \`${TEMP}°C\`

💎 *Estimated Earnings per Day*
• XMR: \`$(printf "%.6f" $XMR_PER_DAY)\`
• USD: \`$$(printf "%.2f" $USD_PER_DAY)\`
• INR: \`₹$(printf "%.2f" $INR_PER_DAY)\`"

    ############################
    #  5️⃣ SEND TO TELEGRAM
    ############################
    echo "📤 Sending mining stats to Telegram..."
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
         -d chat_id="$CHAT_ID" \
         -d text="$MSG" \
         -d parse_mode="Markdown"

    ############################
    #  6️⃣ SLEEP
    ############################
    echo "⏳ Sleeping for $INTERVAL seconds before next update..."
    sleep $INTERVAL

done
