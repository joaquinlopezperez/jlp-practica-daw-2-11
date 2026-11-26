#!/bin/bash 

# -e: el script se detiene en cuanto un comando falla. 

# -x: muestra cada comando antes de ejecutarlo (sirve para depurar). 

set -ex

# Carga las variables del archivo .env (hay que ejecutar desde la carpeta scripts). 

source .env

# Actualiza la lista de paquetes disponibles (no actualiza los programas). 

apt update

# Instala Apache, el servidor web.  -y responde "sí" automáticamente. 

apt install apache2 -y

# Instala PHP y sus extensiones: 

#   libapache2-mod-php -> permite que Apache ejecute PHP 

#   php-mysql          -> conecta PHP con MySQL 

#   php-xml            -> trabaja con XML 

#   php-mbstring       -> textos con tildes, ñ y otros caracteres (UTF-8) 

#   php-curl           -> peticiones a otros servidores 

#   php-zip            -> comprimir y descomprimir (plugins, temas) 

#   php-gd             -> manipular imágenes (miniaturas) 

#   php-intl           -> formatos según el idioma (fechas, números) 

apt install php libapache2-mod-php php-mysql php-xml php-mbstring php-curl php-zip php-gd php-intl -y 


# Instala el servidor de bases de datos MySQL. 

apt install mysql-server -y 


# Copia nuestra configuración del sitio HTTP (puerto 80). 

cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf

# Activa mod_rewrite, necesario para los enlaces permanentes de WordPress. 

a2enmod rewrite 

# Borra la página por defecto de Apache. -f evita el error si ya no existe, 

# así el script se puede ejecutar más de una vez. 

rm -f /var/www/html/index.html 

# Reinicia Apache para aplicar los cambios. 

systemctl restart apache2 
