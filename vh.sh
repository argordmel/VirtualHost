#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#     						 		#
# Script en shell para crear virtualhost en un servidor.	#
# Nota: Recuerden darle permiso de ejecución.  			#
#								#
# Ayuda: En una terminal ejecutamos el archivo			#
#								#
# $ sudo ./virtualhost.sh --help				#
# 								#
# Autor: Iván D. Meléndez - 2013           			#
# Email: argordmel@gmail.com					#
# Licencia: New BSD License					#
#								#
# Este script ha sido testeado en Ubuntu con Apache2.    	#
# 								#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#Ruta por defecto del dominio o subdominio
RUTA="/var/www"
#Nombre del dominio
VIRTUALHOST=""
#Incluir la orden WWW
WWW=true
#Dirección IP del server
IPv4="127.0.0.1"
#Grupo del la carpeta del dominio
GRUPO="www-data"

#Funcion que imprime el uso del script
function helpVH() {
	cat << __EOT
Uso:
$ sudo ./virtualhost.sh --create
$ sudo ./virtualhost.sh --create /path/to/virtualhost
$ sudo ./virtualhost.sh --delete
__EOT
	exit 1
}

# Funcion para crear un virtualhost
function newVH() {	
	# Verifico que el dominio no se encuentre registrado
	if grep -q -E "$VIRTUALHOST" /etc/hosts ; then
		echo " * [ERROR] El dominio $VIRTUALHOST ya se encuentra registrado..."
		echo " * Utilice --delete $VIRTUALHOST si desea eliminar el virtualhost..."
	else 
		echo " * Configurando el virtualhost '$VIRTUALHOST' en la ruta $RUTA"
		# Creo el directorio si no se encuentra
		if [ ! -d $RUTA ]; then
			echo " * Creando diretorios en $RUTA... "
			mkdir -p $RUTA
			mkdir -p $RUTA/private/logs
			mkdir -p $RUTA/private/tmp
			# Asigno los permisos
			chmod 775 $RUTA
			chmod 777 $RUTA/private/logs
			chmod 777 $RUTA/private/tmp
			echo " * Asignando propietario al directorio... "
			chown $USER:$GRUPO -R $RUTA
		else
			if [ ! -d $RUTA/private/logs ]; then
				echo " * Creando diretorio para los archivos de sucesos... "
				mkdir -p $RUTA/private/logs
				# Asigno los permisos
				chmod 777 $RUTA/private/logs
				chown $USER:$GRUPO -R $RUTA
			fi
			if [ ! -d $RUTA/private/tmp ]; then
				echo " * Creando diretorio para los archivos de sesiones... "
				mkdir -p $RUTA/private/tmp
				# Asigno los permisos
				chmod 777 $RUTA/private/tmp
				chown $USER:$GRUPO -R $RUTA
			fi
		fi
		# Creo la entrada en /etc/hosts/
		echo "$IPv4	$VIRTUALHOST" >> /etc/hosts		
		# Creo el archivo de virtualhost
		touch /etc/apache2/sites-available/$VIRTUALHOST
		if $WWW ; then
			echo "	
<VirtualHost *:80>
	ServerAdmin admin@$VIRTUALHOST
	ServerName  $VIRTUALHOST
	ServerAlias www.$VIRTUALHOST
	DocumentRoot $RUTA
	ErrorLog $RUTA/private/logs/access.error.log
	php_value error_log $RUTA/private/logs/php.error.log
    php_value session.save_path $RUTA/private/tmp

	<Directory />
		Options FollowSymLinks
		AllowOverride All
	</Directory>
	<Directory $RUTA/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>
</VirtualHost>" > /etc/apache2/sites-available/$VIRTUALHOST
		else
			echo "
<VirtualHost *:80>
	ServerAdmin admin@$VIRTUALHOST
	ServerName  $VIRTUALHOST
	ServerAlias $VIRTUALHOST
	DocumentRoot $RUTA
	ErrorLog $RUTA/private/logs/access.error.log
	php_value error_log $RUTA/private/logs/php.error.log
    php_value session.save_path $RUTA/private/tmp

	<Directory />
		Options FollowSymLinks
		AllowOverride All
	</Directory>
	<Directory $RUTA/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>
</VirtualHost>" > /etc/apache2/sites-available/$VIRTUALHOST
		fi
		
		# Habilito el virtual host
		echo " * Habilitando el virtualhost..."
		a2ensite $VIRTUALHOST 1>/dev/null 2>/dev/null
	 
		# Reinicio el servidor
		echo " * Reiniciando el servidor apache..."
		/etc/init.d/apache2 reload 1>/dev/null 2>/dev/null

		# Creo el It Works
		touch $RUTA/index.html
		echo "<html>
	<body>
		<h1>It works $VIRTUALHOST!</h1>
		<p>This is the default web page for this server.</p>
		<p>The web server software is running but no content has been added, yet.</p>
	</body>
</html>" > $RUTA/index.html
		# Asigno los permisos
		chmod 775 $RUTA/index.html
		echo " * Virtualhost creado correctamente. $VIRTUALHOST/index.html!"
	fi
	exit 1;
}

# Funcion para eliminar virtualhost
function delVH() {
	
	# Verifico que el virtualhost se encuentre registrado
	if grep -q -E "$VIRTUALHOST" /etc/hosts ; then
		echo -n "Estas seguro de eliminar el virtualhost: $VIRTUALHOST? [S/n]: "
		read continue
		case $continue in
		n*|N*) exit
		esac
		echo " * Conservando los datos en la carpeta del virtualhost..."
		# Remuevo de apache el virtualhost
		echo " * Deshabilitando el virtualhost $VIRTUALHOST del servidor..."
		a2dissite $VIRTUALHOST 1>/dev/null 2>/dev/null
		# Elimino la configuracion del virtualhost
		echo " * Eliminando archivos de configuración..."
		rm /etc/apache2/sites-available/$VIRTUALHOST
		# Elimino el registro del dominio local
		echo " * Removiendo el virtualhost $VIRTUALHOST de /etc/hosts..."
		sed  "/$VIRTUALHOST/ d" -i /etc/hosts
		# Reinicio el servidor
		echo " * Reiniciando el servidor..."
		/etc/init.d/apache2 reload 1>/dev/null 2>/dev/null
		echo " * El dominio se ha eliminado correctamente!"
	else
		echo " * [ERROR] El virtualhost $VIRTUALHOST no existe. Abortando..."
	fi

	exit 1;
}

# Determino si el usuario que ejecuta el archivo tiene privilegios
if [ `whoami` != 'root' ]; then
	echo "Debes tener los privilegios de root para ejecutar el archivo."
	exit
fi

# Determino el nombre de usuario que tiene los privilegios
if [ -z $USER -o $USER = "root" ]; then
	if [ ! -z $SUDO_USER ]; then
		USER=$SUDO_USER
	else
		USER=""
		echo "Error.  Los privilegios que posees no provienen de root."
		exit
	fi
fi

# Capturo los datos
if [ -z $1 ]; then
	helpVH
else
	#Verifico si ejecuta la ayuda
	if [ $1 = "--help" ]; then
		helpVH
	#Verifico si crea un virtualhost
	elif [ $1 = "--create" ]; then

		if [ -z $2 ]; then
			echo -n "Deseas definir el virtualhost en la ubicación $RUTA? [S/n]: "
			read confirmacion
			case $confirmacion in
				n*|N*)
					echo "* [ERROR] Abortando..."
					exit 1;
				;;
			esac
		else
			RUTA=${2%/}
			echo -n "Deseas definir el virtualhost en la ubicación $RUTA? [S/n]: "
			read confirmacion
			case $confirmacion in
				n*|N*)
					echo "* [ERROR] Abortando..."
					exit 1;
				;;
			esac
		fi
	
		#Pido el nombre del virtualhost y lo registro en la variable
		echo -n "Ingresa el nombre del virtualhost (ej: domain.com): "
		read virtual
		if [ -z $virtual ]; then
			echo " * [ERROR] No se ha definido el nombre del virtualhost. Para obtener ayuda utiliza --help"
			exit 1
		else
			VIRTUALHOST=${virtual%/}
		fi

		#Pido si incluye la orden www. antes del dominio
		echo -n "Deseas indicar el alias 'www' al dominio? [S/n]: "
		read confirmacion
		case $confirmacion in
			n*|N*)
				WWW=false
			;;
		esac
			
		#Pido la ip del server
		echo -n "La dirección IPv4 del server es $IPv4? [S/n]: "
		read confirmacion
		case $confirmacion in
			n*|N*)
				echo -n "Ingresa la dirección IPv4 para el server: "
				read ip
				if [ -z $ip ]; then
					echo " * [ERROR] No se ha definido la dirección IPv4 para el virtualhost. Para obtener ayuda utiliza --help"
					exit 1
				else
					IPv4=$ip
				fi
			;;
		esac

		#Confirmo la información digitada
		if [ $IPv4 = "127.0.0.1" ]; then
			echo " * [INFO] Se creará el virtualhost '$VIRTUALHOST' bajo en la ruta $RUTA"
		else
			echo " * [INFO] Se creará el virtualhost '$VIRTUALHOST' bajo la IP '$IPv4' en la ruta $RUTA"
		fi
		echo -n "Deseas continuar? [S/n]:"
		read confirmacion
		case $confirmacion in
			n*|N*)
				exit 1
			;;
		esac
		
		#Ejecuto la función para crear el virtualhost
		newVH
		
	elif [ $1 = "--delete" ]; then
		#Pido el nombre del virtualhost y lo almaceno en la variable
		echo -n "Ingresa el nombre del virtualhost a eliminar: "
		read virtual
		if [ -z $virtual ]; then
			echo " * [ERROR] No se ha definido el nombre del virtualhost. Para obtener ayuda utiliza --help"
			exit 1
		else
			VIRTUALHOST=${virtual%/}
			delVH
		fi
	else
		helpVH
	fi
fi
