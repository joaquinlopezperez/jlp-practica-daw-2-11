#!/bin/bash 
 
# Mostramos los comandos y detenemos el script si hay algún error 
set -ex 
 
# Cargamos las variables del archivo .env 
source .env 
 
# Comprobamos si ya existe un certificado válido para nuestra IP 
if [ -f /etc/ssl/certs/wordpress.crt ] && \ 
   [ -f /etc/ssl/private/wordpress.key ] && \ 
   openssl x509 -in /etc/ssl/certs/wordpress.crt -noout -ext subjectAltName | grep -Fq "IP:$SERVER_NAME"; then 
 
    echo "Ya existe un certificado para $SERVER_NAME." 
 
else 
 
    # Generamos el certificado autofirmado y su clave privada 
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \ 
        -keyout /etc/ssl/private/wordpress.key \ 
        -out /etc/ssl/certs/wordpress.crt \ 
        -subj "/C=ES/O=$CERT_ORGANIZATION/CN=$SERVER_NAME" \ 
        -addext "subjectAltName=IP:$SERVER_NAME" 
 
    # Protegemos la clave privada 
    chmod 600 /etc/ssl/private/wordpress.key 
 
fi 
 
# Copiamos la configuración HTTPS de nuestro repositorio a Apache 
cp ../conf/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf 
 
# Sustituimos el nombre provisional por nuestra IP elástica 
sed -i "s|PUT_YOUR_SERVER_NAME_HERE|$SERVER_NAME|" /etc/apache2/sites-available/default-ssl.conf 
 
# Activamos la redirección de HTTP a HTTPS en la configuración original 
sed -i "s|#Redirect permanent / https://PUT_YOUR_SERVER_NAME_HERE/|Redirect permanent / https://$SERVER_NAME/|" ../conf/000-default.conf 
 
# Copiamos la configuración HTTP actualizada a Apache 
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf 
 
# Activamos el módulo SSL 
a2enmod ssl 
 
# Activamos el sitio HTTPS 
a2ensite default-ssl 
 
# Comprobamos que la configuración de Apache no tiene errores 
apache2ctl configtest 
 
# Recargamos Apache para aplicar los cambios 
systemctl reload apache2 
 
echo "Configuración HTTPS completada correctamente." 
