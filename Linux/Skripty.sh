_______________________ Skript tutorial _______________________
nano - text editor

Každý skript musí byť musíme následne nastaviť na execute chmod +x skript.sh 

#každý skript by mal vyzerať následovne:

#!/bin/bash

# Author: David Dopirak
# Date Created: 1.8.2023
# Last MOdified: 1.8.2023
# Description: Print text to screen

# Usage: Script for making backup.

tar -cvf ~/bash_course/my_backup_"$(date +%d-%m-%Y_%H-%M-%S)".tar ~/* 2>/dev/null

_______________________

#!/bin/bash-  - určujem v ktorom jazyku budem písať skript, a musí byť na začiatku každého skriptu, aby shell vedel, že sa jedná o skript.
#!Shebang musí byť na začiatku každého skriptu


bash skript.sh #spustenie skriptu

# na konci skriptu by nemal chýbať exit kód
	exit 0

# _______________________ Quoting _______________________
# 3 typy zápisu citácií
#	spatné lomítko \backslash\ - odstranuje specialny vyznam dalsieho pismena
#	jednoduche uvodzovdky 'single qoutes' - odstranuju spec. vyznam pre vsetky znaky vramci uvodzoviek
#	dvojite uvodzovky "double qoutes" - odstranuje spec. vyznam zo vsetkych znakov okrem symbolu dolar $, spatného lomitka \ a #`backsticks`
#										- to znamena dolar ma vzdy specialny vyznam vramci ""

#Priklady:
echo john \& jane
filepath=C:\\Users\\sk8er\\Documents\\David #spatné lomitka musime odeskejpovat alebo pouzit jednoduche uvodzovky
filepath1='C:\Users\sk8er\Documents\David' #nemoze obsahovat dalsiu jednoduchu uvodzovku
filepath="C:\Users\\$USER\Documents\David" #moze obsahovat dolar a ` backsticks`, ak je dolar tak musime ho odeskapovat

#Command zapis s argumentom
	  #mozny zapis commandu a argumentu 
	  command: ["sleep","10"] #prva pozicia je vzdy command [entrypoint] ostane pozicie su argumetny [CMD]
	  #pripadne
	  command:
	  - "sleep"
	  - "10"
	  #toto je najprehladnejsia forma
	  command: ["sleep2.0"] #prepisuje ENTRYPOINT
	  args: ["10"] 	#prepisuje CMD prikaz v docker file,
					#argument, ktory sa vlozi do premnennej sleep, viz docker file


# ------ Skript na automatizaciu zapisu public kľúča - SSH -----
#najprv je potrebné si nainštalovať sshpass
for user in ansible root
 do
   for os in ubuntu centos
   do
     for instance in 1 2 3
     do
       sshpass -f password.txt ssh-copy-id -o StrictHostKeyChecking=no ${user}@{$os}{$instance}
     done
   done
 done










