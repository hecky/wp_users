#!/bin/bash
#./wp_users V 0.1
#Author: 	hecky
#Web: 		Neobits.org
#Twitter: 	@hecky
#Mail: 		hecky@neobits.org

user_agent="Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:15.0) Gecko/20100101 Firefox/15.0.1"
argumentos=$#
url=$1
tries=$2
limpia=$(echo $tries | egrep -q [a-zA-Z]; echo $? | tail -1 )
not_url=$(echo $1 | egrep -q [a-zA-Z]"\."[a-zA-Z]"{2,5}"; echo $? | tail -1)

function validar_argumentos(){
if [ $argumentos -eq 1 ] && [ $url == "--help" ]; then
	echo -e "\n >> \e[1;33;41m<URL>\e[m\tURL de la pagina\t(Si se copia la direccion de la barra de navegacion de un navegador, \e[1;31mEVITAR la ultima diagonal\e[m)"
	echo -e "\n    \t\tEj:"
	echo -e "\n\t\t\thttp://neobits.org\t\e[1;33m=)\e[m"
	echo -e "\n\t\t\thttp://neobits.org\e[1;36;41m/\e[m\t\e[1;33m=(\e[m"
	
	echo -e "\n >> \e[1;33;41m<Numero de Intentos>\e[m\tNumero de intentos que se utilizara en el ciclo\t(Dependiendo del numero sera la cantidad de usuarios obtenidos)"
	echo -e "\n\t\t\tSugerido \e[1;36m100\e[m para Wordpress que \e[1;33mNO\e[m permiten registro de usuarios"
	echo -e "\n\t\t\tSugerido \e[1;36m300+\e[m para Wordpress que \e[1;33mSI\e[m permiten registro de usuarios"

	echo -e "\n >> \e[1;33;41m--check\e[m\tWordpress Checker:"
	echo -e "\n\t\t\tEn este modo interactivo se puede comprobar mediante algunas busquedas basicas, si un sitio esta usando Wordpress o no" 
	
	echo -e "\n >> \e[1;33;41m--inurl\e[m\tObtain Usernames from url:"
	echo -e "\n\t\t\tEn este modo puedes probar obtener los usuarios por el metodo de redireccion del \e[1;4;34mpagina.com/?author=ID\e[m a \e[1;4;34mpagina.com/author/AUTOR/\e[m..."
	echo -e "\t\t\tSe recomienda hacer uso de este metodo si en el normal obtuviste ID's pero con nombres vacios" 	
	
	echo -e "\n\n\e[1;4;7;33;41mNota:\e[m \e[1;31m./wp_users\e[m \e[1;35mspoofea\e[m por defecto la cabecera \e[1;35mUser-Agent\e[m con la siguiente cadena: \e[4;36m$user_agent\e[m (simulando un Linux de 32 bits con Firefox 15.0), esto con el fin de evadir los bloqueos de algunos htaccess. Este valor se puede cambiar en la octava linea del script"
	echo -e "\n\t<<< \e[1;36m@hecky\e[m from \e[1;36mNeobits.org\e[m >>>"
	exit
elif [ $argumentos -eq 1 ] && [ $url == "--check" ]; then
	echo -e "<< Ingresa la url de la pagina para verificar si es un wordpress >>\n"
	read pagina
	url_real=$(echo $pagina | egrep -q [a-zA-Z]"\."[a-zA-Z]"{2,5}"; echo $? | tail -1)
	if	[ $url_real -eq 1 ]; then
		echo -e "No parece una URL valida"
		exit
	fi
	echo -e "\nEspere...Verificando \e[1;33;41m$pagina\e[m\n"	
	test1=$(GET -H "User-Agent: $user_agent" "$pagina/wp-login.php" -s | head -1)
	test2=$(GET -H "User-Agent: $user_agent" "$pagina/wp-admin/" -s | head -1)
	test3=$(GET -H "User-Agent: $user_agent" "$pagina/wp-content/" -s | head -1)
	test4=$(GET -H "User-Agent: $user_agent" "$pagina/wp-includes/" -s | head -1)
	test5=$(GET -H "User-Agent: $user_agent" "$pagina/readme.html" -s | head -1 | grep 200 -q ; echo $?)
	echo -e "> \e[36mwp-login.php\e[m = \e[1;31m"$test1"\e[m\n"
	echo -e "> \e[36mwp-admin/\e[m = \e[1;31m"$test2"\e[m\n"
	echo -e "> \e[36mwp-content/\e[m = \e[1;31m"$test3"\e[m\n"
	echo -e "> \e[36mwp-includes/\e[m = \e[1;31m"$test4"\e[m\n"
	if [ "$test5" -eq 1 ];then 	
			echo -e "> \e[36mreadme.html\e[m = \e[1;31mParece no existe este archivo (Normalmente es/DEBERIA ser borrado)\e[m\n"
	else	
		version=$(GET -H "User-Agent: $user_agent" "$pagina/readme.html" | egrep -i "Version "[0-9]\.+$ -om 1 | sed 's/<\/h1>//g')
		echo -e "> \e[36mreadme.html\e[m = Posiblemente \e[1;31m"$version"\e[m\n"
	fi
	echo -e "\n\e[4;37mNota: Los directorios\e[m \e[36mwp-content/\e[m \e[4;37my\e[m \e[36mwp-includes/\e[m \e[4;37mpueden mostrar diferentes errores (403,404,etc...) esto es normal ya que el webmaster puede personalizar la respuesta del servidor a voluntad. Estos errores no deben tomarse como referencia definitiva.\e[m\n"
	if [ $(echo $test1 | grep -qe "200" -e "403" ; echo $?) -eq 0 ]; then
		count_test=1
	else
		count_test=0
	fi
	if [ $(echo $test2 | grep -qe "200" -e "403"; echo $?) -eq 0 ]; then
		let $((count_test++))
	else
		count_test=0
	fi
	if [ $count_test -eq 2 ];then
		echo -e "\t\e[1;33m<< Esta pagina parece contener los elementos Necesarios para considerarlo un Wordpress\e[m \e[1;33;41m;)\e[m \e[1;33m>>\e[m\n"
	else
		echo -e "\t\e[1;33m<< Parece que este sitio NO esta usando wordpress\e[m \e[1;33;41mU_U\e[m \e[1;33m>>\e[m\n"
	fi
	exit
elif [ $argumentos -eq 1 ] && [ $url == "--inurl" ]; then
	echo -e "\t<< En este modo puedes probar obtener los usuarios por el metodo de redireccion del \e[1;4;34mpagina.com/?author=ID\e[m a \e[1;4;34mpagina.com/author/AUTOR/\e[m... >>\n"
	echo -e "\t   \e[1;4mSe recomienda hacer uso de este metodo si en el normal obtuviste ID's pero con nombres vacios\e[m\n"
	read -p "Ingresa la url de la pagina: " web
	read -p "Numero de Intentos: " num
	clear
	echo -e "Tratando de obtener usuarios de: \e[1;33;41m$web\e[m ( \e[4;35m$num intentos\e[m )\n\t<<< \e[1;36m@hecky from Neobits.org\e[m >>>\n"
	for ((i=1;i<=$num;i++)); do
	if [ $i -eq 1 ];then
		echo -n "" > "wp_users-"$web".txt"
	fi
	if (GET -H "User-Agent: $user_agent" "$web/?author=$i" -s | head -1 | grep -q 200); then
		users=$(GET -H "User-Agent: $user_agent" "$web/?author=$i" | egrep -i "$web/author/.*+/" -om1 | sed "s/$web\/author//g" | cut -d"/" -f1-2 | tr -d "/")
		echo -en "Existe usuario con ID = \e[1;33m"$i"\e[m ( \e[1;31m"$users"\e[m )\n"
		echo "ID = "$i" ( $users )" >> "wp_users-"$web".txt"
	fi	
	done
	echo "Se guardaron los resultados en wp_users-$web.txt"
	exit

elif [ $argumentos -eq 0 ] || [ $argumentos -eq 1 ] || [ $argumentos -gt 2 ] || [ $not_url -eq 1 ]; then
	echo -e "\n\e[1;31m./wp_users\e[m enumera y obtiene los usuarios registrados en \e[1;2;35mWordpress\e[m\n"
	echo -e "\t\e[1;33;41mUso: ./wp_users <URL> <Numero de Intentos>\e[m"
	echo -e "\n\nMostrar dialogo de ayuda: \e[1;33m./wp_users --help\e[m"
	echo -e "\nVerificar si se trata de un Wordpress: \e[1;33m./wp_users --check\e[m"
	echo -e "\n(Metodo 2) Obtencion de usuarios desde URL: \e[1;33m./wp_users --inurl\e[m"
	echo -e "\n\n\t<<< \e[36m@hecky\e[m from \e[36mNeobits.org\e[m >>>"
	exit
elif [ $argumentos -eq 2 ] && [ $tries -eq 0 &> /dev/null ] || [ $limpia -eq 0 ];then 
	echo "El segundo argumento debe ser un Numero entero mayor a 0"
	exit
fi

}

function verificacion_rapida(){
test1=$(GET -H "User-Agent: $user_agent" "$url/wp-login.php" -s | head -1)
if [ $(echo $test1 | grep -qe "200" -e "403" ; echo $?) -eq 1 ]; then
		echo -e "Seguro es un wordpress? Verifica primero con \e[1;33;41m./wp_users --check\e[m"
		exit
fi
}


validar_argumentos
verificacion_rapida

declare -i k="0"
echo -e "Identificando posibles usuarios de Wordpress de: \e[1;33;41m$1\e[m ( \e[4;35m$tries intentos\e[m )\n\t<<< \e[1;36m@hecky from Neobits.org\e[m >>>\n"
for ((i=1;i<=$tries;i++)); do
	if (GET -H "User-Agent: $user_agent" "$1/?author=$i" -s | head -1 | grep -q 200); then
		users=$(GET -H "User-Agent: $user_agent" "$1/?author=$i" | egrep "author-".+ -o | cut -d" " -f1 | cut -d"-" -f2- | sed 's/">//g' | head -1)
		empty_users+=$users
		let $((k++))		
		echo -en "Existe usuario con ID = \e[1;33m"$i"\e[m ( \e[1;31m"$users"\e[m )\n"
		if [ -z "$empty_users" -a $k -eq 5 ]; then
echo -e "\e[3;4m<< Si fue posible identificar ID's pero los nombres de usuario aparecen vacios, intenta en la forma interactiva con\e[m \e[1;33;41m./wp_users --inurl\e[m >>\n"
		elif [ -z "$empty_users" -a $k -eq 10 ]; then
echo -e "\n\e[3;4m<< En serio, parece asi no lograremos nada; intenta en la forma interactiva con\e[m \e[1;33;41m./wp_users --inurl\e[m >>\n"
		 	exit
		fi
	fi
done