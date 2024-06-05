#!/bin/bash

# Función para listar dispositivos USB disponibles
listar_usb() {
    echo "Listado de dispositivos USB disponibles:"
    lsblk -o NAME,SIZE,TYPE | grep -E 'disk|part' | grep -vE 'sda|nvme' | awk '{print $1, $2}' > /tmp/usb_list.txt
    count=1
    while read -r line; do
        echo "$count. USB $line"
        count=$((count + 1))
    done < /tmp/usb_list.txt
}

# Solicitar la ruta de la imagen ISO
echo "Por favor, introduce la ruta de la imagen ISO de Rocky Linux:"
read iso_path

# Verificar si el archivo ISO existe
if [ ! -f "$iso_path" ]; then
    echo "El archivo ISO no existe. Por favor, verifica la ruta y vuelve a intentarlo."
    exit 1
fi

# Listar los dispositivos USB
listar_usb

# Solicitar al usuario que seleccione el USB por número
echo "Por favor, introduce el número del dispositivo USB que deseas usar:"
read usb_number

# Obtener el nombre del dispositivo USB seleccionado
usb_device=$(sed "${usb_number}q;d" /tmp/usb_list.txt | awk '{print $1}')

# Verificar si el dispositivo USB es válido
if [ ! -b "/dev/$usb_device" ]; then
    echo "El dispositivo seleccionado no es válido. Por favor, verifica y vuelve a intentarlo."
    exit 1
fi

# Confirmar con el usuario antes de proceder
echo "Vas a grabar la imagen ISO en el dispositivo /dev/$usb_device. ¡Esto borrará todos los datos en el dispositivo!"
echo "¿Estás seguro que deseas continuar? (escribe 'si' para confirmar)"
read confirmacion

if [ "$confirmacion" != "si" ]; then
    echo "Operación cancelada por el usuario."
    exit 1
fi

# Grabar la imagen ISO en el dispositivo USB utilizando dd con pv para la barra de progreso
echo "Grabando la imagen ISO en el dispositivo USB..."

# Obtener el tamaño del archivo ISO para calcular el progreso
iso_size=$(stat -c%s "$iso_path")

#instalar pv
sudo dnf install pv -y

# Utilizar pv para mostrar una barra de progreso con color verde
pv -ptebar -s "$iso_size" "$iso_path" | sudo dd of="/dev/$usb_device" bs=4M oflag=sync status=none

echo -e "\n\033[0;32mLa grabación se ha completado. Puedes desmontar el USB de forma segura.\033[0m"

