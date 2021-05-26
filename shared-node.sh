#!/bin/bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install git npm unzip curl screen -y

mkdir datadir && cd datadir
mkdir idenachain.db && cd idenachain.db
#wget "https://idena.site/idenachain.db.zip"
wget "https://sync.idena.site/idenachain.db.zip"
unzip idenachain.db.zip && rm idenachain.db.zip
cd ..
cd ..

curl -s https://api.github.com/repos/idena-network/idena-go/releases/latest \
| grep browser_download_url \
| grep idena-node-linux-0.* \
| cut -d '"' -f 4 \
| wget -qi -
mv idena-* idena-go && chmod +x idena-go
bash -c 'echo "{\"IpfsConf\":{\"Profile\": \"server\" ,\"FlipPinThreshold\":1},\"Sync\": {\"LoadAllFlips\": true}}" > config.json'

touch node-restarted.log

bash -c 'echo "while :
do
./idena-go --config=config.json --apikey=95e76e2819f78c3bebf4b61967772d70
date >> node-restarted.log
done" > start'
chmod +x start
(crontab -l 2>/dev/null; echo "@reboot screen -dmS node $PWD/start") | crontab -

npm i npm@latest -g
git clone https://github.com/idena-network/idena-node-proxy
npm i -g pm2

cd idena-node-proxy

bash -c 'echo "AVAILABLE_KEYS=[\"api1\",\"api2\",\"api3\",\"api4\",\"api5\",\"api6\",\"api7\",\"api8\",\"api9\",\"api10\",\"api11\",\"api12\",\"api13",\"api14\",\"api15\",\"api16\",\"api17\",\"api18",\"api19"\,\"api20\"]
IDENA_URL=\"http://localhost:9009\"
IDENA_KEY=\"95e76e2819f78c3bebf4b61967772d70\"
PORT=80 > .env'

npm install
npm start
pm2 startup
reboot
