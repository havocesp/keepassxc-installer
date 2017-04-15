#!/bin/bash

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

if [ $# -ne 1 ];then
    echo " - [WARN] Usando $INSTALL_DIR como directorio de instalación para KeePassXC."
    INSTALL_DIR="$HOME/.local/share"
else
    INSTALL_DIR="$1"
fi

if [ -d "$INSTALL_DIR/keepassxc" ];then
    echo " - [INFO] Detectada instalación anterior, intentando actualizarla."
    echo " - [DEBUG] Entrando a $INSTALL_DIR"
    cd "$INSTALL_DIR"
    cd keepassxc
    git pull > /dev/null
    if [ "$?" -ne 0 ];then
        echo " - [ERROR] Fallo durante la descarga de datos desde GitHub."
        exit 1
    fi
else

    mkdir -p "$INSTALL_DIR"
    if [ $? -ne 0 ];then
        echo " - [ERROR] No se pudo crear el directorio $INSTALL_DIR."
        exit 1
    fi
    cd "$INSTALL_DIR"
    git clone "https://github.com/keepassxreboot/keepassxc.git" > /dev/null
    if [ $? -ne 0 ];then
        echo " - [ERROR] Fallo durante la descarga de datos desde GitHub."
        exit 1
    else
        cd keepassxc
    fi

fi

echo " - [INFO] Compilando ..."
[ -d "$INSTALL_DIR/keepassxc/build" ] || mkdir build
cd build
cmake -DWITH_TESTS=OFF -DWITH_XC_HTTP=ON .. > /dev/null && make -j8 > /dev/null
[ $? -ne 0 ] && exit 1

# TODO permitir elegir opciones de compilación


read -p "  - ¿Desea instalar KeePassXC para todos los usuarios (se usará sudo)? (S/N): " yesno
if [ -n "$yesno" ] && ([ "$yesno" == "S" ] || [ "$yesno" == "s" ]);then
    sudo make install > /dev/null
fi
