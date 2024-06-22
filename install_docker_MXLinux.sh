#!/bin/bash

# Verificar si el usuario tiene privilegios de sudo
if [ "$(id -u)" != "0" ]; then
    echo "Este script debe ser ejecutado con privilegios de superusuario (sudo)"
    exit 1
fi

# Actualizar el sistema
apt update
apt upgrade -y

# Instalar dependencias necesarias
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Agregar la clave GPG oficial de Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Configurar el repositorio estable de Docker
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar el índice de paquetes
apt update

# Instalar Docker Engine
apt install -y docker-ce docker-ce-cli containerd.io

# Verificar que Docker se haya instalado correctamente
docker --version

# Agregar el usuario actual al grupo docker para ejecutar comandos Docker sin sudo
usermod -aG docker $(whoami)

# Informar al usuario que necesita cerrar sesión e iniciar sesión nuevamente para aplicar los cambios
echo "Docker se ha instalado correctamente."
echo "Para aplicar los cambios, por favor cierre sesión e inicie sesión nuevamente."

