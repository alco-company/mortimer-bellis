#!/bin/bash

# Fichier généré par Mistral.ai
# Auteur : Roland Laurès
# License MIT

# Vérifier si la commande convert est installée
if ! command -v magick &> /dev/null
then
    # Détecter le système d'exploitation
    if [[ -f /etc/os-release ]]; then
        # Utiliser le fichier /etc/os-release pour détecter le système d'exploitation
        . /etc/os-release
        if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
            echo "La commande 'convert' n'est pas installée. Veuillez l'installer avec la commande suivante :"
            echo "sudo apt-get update"
            echo "sudo apt-get install imagemagick"
        elif [[ "$ID" == "fedora" ]]; then
            echo "La commande 'convert' n'est pas installée. Veuillez l'installer avec la commande suivante :"
            echo "sudo dnf install ImageMagick"
        fi
    elif [[ -f /etc/redhat-release ]]; then
        # Détecter le système d'exploitation Red Hat ou CentOS
        if [[ -f /etc/centos-release ]]; then
            echo "La commande 'convert' n'est pas installée. Veuillez l'installer avec la commande suivante :"
            echo "sudo yum install ImageMagick"
        else
            echo "La commande 'convert' n'est pas installée. Veuillez l'installer avec la commande suivante :"
            echo "sudo dnf install ImageMagick"
        fi
    elif [[ "$(uname)" == "Darwin" ]]; then
        # Détecter macOS
        echo "La commande 'convert' n'est pas installée. Veuillez l'installer avec la commande suivante :"
        echo "brew install imagemagick"
    else
        echo "La commande 'convert' n'est pas installée. Veuillez l'installer avec le gestionnaire de paquets de votre système d'exploitation."
    fi
    exit 1
fi

# Définir les dimensions des favicons à générer
declare -a SIZES=(16 24 32 48 64 76 96 120 128 152 167 180 192 256 384 512)

# Définir le chemin du fichier source
SOURCE_FILE="$1"

# Créer un dossier pour stocker les favicons générés
rm -fr app/assets/images/favicons
mkdir -p app/assets/images/favicons

# Boucler sur les dimensions des favicons à générer
for size in "${SIZES[@]}"
do
  # Générer le favicon avec la taille actuelle
  echo -n "Conversion vers ${size}x${size}..."
  magick "$SOURCE_FILE" -resize "${size}x${size}" "app/assets/images/favicons/favicon-${size}x${size}.png"
  echo 'fait.'
done