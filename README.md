VirtualHost
===========

Script en shell para crear VirtualHost en ubuntu con apache2

Licencia: New BSD

Autor: Iván D. Meléndez - 2013

Uso
--------

* Darle permisos de ejecución

        $ chmod +x vh.sh
        
        
* Creando un VirtualHost

        $ sudo ./vh.sh --create                        
                
        Deseas definir el virtualhost en la ubicación /var/www? [S/n]: (enter)
        Ingresa el nombre del virtualhost (ej: domain.com): prueba1.com
        Deseas indicar el alias 'www' al dominio? [S/n]: s
        La dirección IPv4 del server es 127.0.0.1? [S/n]: (enter)
        * [INFO] Se creará el virtualhost 'prueba.com' bajo en la ruta /var/www
        Deseas continuar? [S/n]: (enter)
                        

        
* Creando un VirtualHost en una ruta específica

        $ sudo ./vh.sh --create /home/user/www-app
        
        Deseas definir el virtualhost en la ubicación /home/user/www-app? [S/n]: (enter)
        Ingresa el nombre del virtualhost (ej: domain.com): prueba2.com
        Deseas indicar el alias 'www' al dominio? [S/n]: s
        La dirección IPv4 del server es 127.0.0.1? [S/n]: (enter)
        * [INFO] Se creará el virtualhost 'prueba.com' bajo en la ruta /home/user/www-app
        Deseas continuar? [S/n]: (enter)
        
        
* Eliminando un VirtualHost        
        
        $ sudo ./vh.sh --delete
        
        Ingresa el nombre del virtualhost a eliminar: prueba1.com
        Estas seguro de eliminar el virtualhost: prueba1.com? [S/n]: (enter)


Nota
----------
El script creará una carpeta dentro del virtual host llamada *private* la cual no se debe eliminar
  
