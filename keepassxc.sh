#!/bin/bash

INSTALL_DIR="$HOME.local/share"

echo
echo "  [KeePassXC]"
echo
echo " - Autor:         Daniel J. Umpierrez"
echo " - Version:       0.01"
echo " - GitHub:        https://github.com/havocesp/keepassxc-installer"
echo " - Descripcion:   Programa de instalación para Debian/Ubuntu/Linux Mint"
echo

DEPENDENCIES=""

echo " - [INFO] Comprobando dependencias ..."
which git > /dev/null || DEPENDENCIES="git"
which cmake > /dev/null || DEPENDENCIES="$DEPENDENCIES cmake"
which g++ > /dev/null  || DEPENDENCIES="$DEPENDENCIES g++"
which gcc > /dev/null || DEPENDENCIES="$DEPENDENCIES build-essential"
#dpkg-query --show qtbase5-gles-dev &> /dev/null || DEPENDENCIES="$DEPENDENCIES qtbase5-gles-dev"
dpkg-query --show qtbase5-dev &> /dev/null || DEPENDENCIES="$DEPENDENCIES qt5-default" # qtbase5-dev"
dpkg-query --show qttools5-dev-tools &> /dev/null || DEPENDENCIES="$DEPENDENCIES qttools5-dev-tools"
dpkg-query --show libgpg-error-dev &> /dev/null || DEPENDENCIES="$DEPENDENCIES libgpg-error-dev"
dpkg-query --show libgcrypt20-dev &> /dev/null || DEPENDENCIES="$DEPENDENCIES libgcrypt20-dev"
dpkg-query --show libqt5x11extras5-dev &> /dev/null || DEPENDENCIES="$DEPENDENCIES libqt5x11extras5-dev"

which make > /dev/null || DEPENDENCIES="$DEPENDENCIES make"

if [ -n "$DEPENDENCIES" ];then
    echo " - Los siguientes paquetes son necesarios: $DEPENDENCIES"
    read -p " - ¿Desea instalarlos ahora usando 'sudo'? (S/N): " yesno
    if [ -n "$yesno" ] && ([ "$yesno" == "S" ] || [ "$yesno" == "s" ]);then
        sudo apt-get -y install $DEPENDENCIES
        if [ $? -ne 0 ];then
            echo " - [ERROR] No se pudo instalar las dependencias."
            exit 1
        fi
    else
        exit 0
    fi
else
    echo " - [INFO] Todas las dependencias estan satisfechas."
fi

if [ "$#" -ne 1 ];then
    echo " - [WARN] Usando $INSTALL_DIR como directorio de instalación para KeePassXC."
else
    INSTALL_DIR="$1"
fi

if [ ! -d "$INSTALL_DIR" ];then
    mkdir "$INSTALL_DIR"
    if [ "$?" -ne 0 ];then
        echo " - [ERROR] No se pudo crear el directorio $INSTALL_DIR."
        exit 1
    fi
    cd "$1"
    git clone "https://github.com/keepassxreboot/keepassxc.git" > /dev/null
    if [ $? -ne 0 ];then
        echo " - [ERROR] Fallo durante la descarga de datos desde GitHub."
        exit 1
    else
        cd keepassxc
    fi
else
    echo " - [INFO] Detectada instalación anterior, intentando actualizarla."
    cd "$1/keepassxc"
    git pull > /dev/nulls
    if [ "$?" -ne 0 ];then
        echo " - [ERROR] Fallo durante la descarga de datos desde GitHub."
        exit 1
    fi
fi

echo " - [INFO] Compilando ..."
[ ! -d ] && mkdir build
cd build
cmake -DWITH_TESTS=OFF -DWITH_XC_HTTP=ON .. > /dev/null && make -j8 > /dev/null
[ $? -ne 0 ] && exit 1

# TODO comprobacines de que no falla la compilación


read -p "  - ¿Desea instalar KeePassXC para todos los usuarios (se usará sudo)? (S/N): " yesno
if [ -n "$yesn"o ] && ([ "$yesno" == "S" ] || [ "$yesno" == "s" ]);then
    sudo make install > /dev/null
fi
