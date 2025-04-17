#!/bin/bash

# Script con confirmación paso a paso para instalar Hyperledger Fabric 3.1.0 en Ubuntu 22.04 LTS

set -e

function pause() {
  read -p "Presiona ENTER para continuar..."
}

FABRIC_VERSION=3.1.0
CA_VERSION=1.5.7
GO_VERSION=1.22.2

echo "🚀 Iniciando la instalación para Ubuntu 22.04 LTS..."
pause

echo "📦 Actualizando paquetes del sistema..."
sudo apt update && sudo apt upgrade -y
pause

echo "📦 Instalando herramientas esenciales..."
sudo apt install -y git curl unzip jq wget apt-transport-https ca-certificates gnupg lsb-release software-properties-common
pause

echo "🐳 Instalando Docker Engine..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true
pause

# Repositorio oficial de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
pause

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
pause

echo "🧑‍🔧 Agregando usuario al grupo docker..."
sudo usermod -aG docker $USER
pause

echo "🐹 Instalando Go $GO_VERSION..."
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
pause

echo "🌐 Configurando entorno Go..."
{
  echo 'export PATH=$PATH:/usr/local/go/bin'
  echo 'export GOPATH=$HOME/go'
  echo 'export PATH=$PATH:$GOPATH/bin'
} >> ~/.bashrc

source ~/.bashrc
pause

echo "📦 Instalando Node.js 20.x (LTS recomendado para chaincode)..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "📦 Verificando instalación de Node.js y npm..."
node -v
npm -v
pause

echo "🧱 Descargando Hyperledger Fabric v$FABRIC_VERSION y componentes..."
mkdir -p $HOME/hyperledger
cd $HOME/hyperledger
pause

if [ ! -d "fabric-samples" ]; then
  git clone --depth 1 https://github.com/hyperledger/fabric-samples.git
fi
cd fabric-samples
pause

curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh | bash -s -- $FABRIC_VERSION $CA_VERSION -s
pause

echo "✅ Instalación completa de Hyperledger Fabric ${FABRIC_VERSION}"
echo "📁 Ubicación: $HOME/hyperledger/fabric-samples"
echo 'export PATH=$PATH:$HOME/hyperledger/fabric-samples/bin' >> ~/.profile
source ~/.profile
pause

echo "⚙️ Levantando test-network..."
cd test-network
./network.sh down || true
pause
./network.sh up

echo "🎉 Entorno listo para usar Hyperledger Fabric 3.1.0 en Ubuntu 22.04 LTS"
echo "📝 Recuerda cerrar y volver a abrir la terminal o ejecutar: source ~/.bashrc"
