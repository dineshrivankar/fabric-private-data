#!/bin/bash

source .env
export PATH=$PATH:${PWD}/bin
export FABRIC_CFG_PATH=${PWD}

# ---------------------------------------------------------------------------
# Clear screen
# ---------------------------------------------------------------------------
clear

echo "# ---------------------------------------------------------------------------"
echo "# Remove old artifacts"
echo "# ---------------------------------------------------------------------------"
rm -fr crypto-config/* config/*

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate crypto material"
echo "# ---------------------------------------------------------------------------"
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate genesis block for orderer"
echo "# ---------------------------------------------------------------------------"
configtxgen -profile OrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate channel configuration transaction for My Channel"
echo "# ---------------------------------------------------------------------------"
configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./config/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME

if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate anchor peer for ORG1 Org"
echo "# ---------------------------------------------------------------------------"
configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./config/Org1MSPanchors_${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate anchor peer for ORG2 Org"
echo "# ---------------------------------------------------------------------------"
configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./config/Org2MSPanchors_${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi

sleep 3 

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Remove old crypto material"
echo "# ---------------------------------------------------------------------------"
rm -rf mkdir /var/mynetwork/*

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Create directories to copy crypto material"
echo "# ---------------------------------------------------------------------------"
mkdir -p /var/mynetwork/chaincode /var/mynetwork/certs /var/mynetwork/bin /var/mynetwork/fabric-src

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Clone fabric repository"
echo "# ---------------------------------------------------------------------------"
git clone https://github.com/hyperledger/fabric /var/mynetwork/fabric-src/hyperledger/fabric
cd /var/mynetwork/fabric-src/hyperledger/fabric
git checkout release-1.4

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Copy new crypto material"
echo "# ---------------------------------------------------------------------------"
cd -
cp -R crypto-config /var/mynetwork/certs/
cp -R config /var/mynetwork/certs/
cp -R chaincodes/* /var/mynetwork/chaincode/
cp -R bin/* /var/mynetwork/bin/

sleep 3 

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Deploy Orderer node"
echo "# ---------------------------------------------------------------------------"
docker stack deploy --compose-file docker-compose-orderer.yml orderer
sleep 5 

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Deploy Org1 nodes"
echo "# ---------------------------------------------------------------------------"
docker stack deploy --compose-file docker-compose-org1.yml org1
sleep 3 

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Deploy Org2 nodes"
echo "# ---------------------------------------------------------------------------"
docker stack deploy --compose-file docker-compose-org2.yml org2
sleep 3 
