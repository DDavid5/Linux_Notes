CTRL+C - zrušenie vstupu
CTRL+D - odhlásenie

apropos - vyhľadaj kľúčove slovo

Skrolovanie 
D, U používam na skrolovanie v manuali, keď hľadám cez /

File system
var - tam nájdem Log files
temp - temporary files
home - existujúci užívatelia
dev - pripojené zariadenia (HDD, SSD)
etc - nastavenia
media - zariadenia ako SD, alebo USB 
bin - všetky príkazy, môžem vytvoriť bin v každom užívateľovi, ale potom musím tu cestu pridať "export PATH=$PATH:$HOME/bin" do ~/.bashrc (cez nano)
	nano ~/.bashrc
	a na koniec pridať export PATH=$PATH:$HOME/bin
	potom aby sa zmena potvrdila je potrebné "source ~/.bashrc"
	a potom cez chmod pridať x 
	
etc/group - nastavenia jednotlivej grupy

Inštalovanie softvéru

chmod u+x <file> # urobí súbor pre user executable X  
chown - Change the owner and/or group of each FILE to OWNER and/or GROUP.
read číta zadanie z klávesnice read name
 
Prikazy na čítanie súborov:
cat
tac - číta súbor(riadky) v opačnom poradí ako cat (otočí to hore nohami) (vertikálne - stlpcove)
rev - otočí obsah každého riadku (horizontálne, riadkové)
less - podobne ako cat ale môžeme skrolovať od hora a postupne prehliadať, zatvorím to písmenom Q.
head - zobrazí len prvých 10 riadkov, -n určí koľko riadkov chceme zobraziť  
tail - opak head
cut - oreže data

Redirection - ak urobíme redirection už nieje možné PIPovať

0> output
0< input
2> error

xargs - ak command neakceptuje STDIN, tak použiješ xargs, zmení input na 
tee - križovatka - napr uloží do súboru a vypíše v konzole napr:
date | tee fulldate.txt | cut -d " " -f  - t.j. do súboru uloží plný dátum a na konzole vypíše len prvý stlpec
touch vytvorí súbor
mkdir - vytvorí zložku
	mkdir -p /z1/z2 #ak cesta neexistuje tak vytvorí rodicovské 


#koment

if [[ $beast || $neco == 1]]
fi # ukončuje podmienku
case 
	1)
	;;
	2)
	;;
esac # ukončuje case

systemctl status/start/stop...  #test status apache2,sql,php... 

sudo !! #predošlý príkaz s root opravnením

man a následne príkaz /dir  -- hľadám zadaný výraz - D, U presúvam medzi hľadným výrazom

which - príkaz ktorý zisti cestu k executable files


w #zobrazí kto je prihlásený a čo robí

sudo su - #root

Automatic upgrade - Unattended upgrades =============
sudo apt install unattended-upgrades #softvér na zistenie aktualizácií
sudo dpkg-reconfigure --priority=low unattended-upgrades  #spustenie
apt-get 

df #discfree skontroluje miesto na disku
du -a / #zisti využitie na disku pre všetky súbory v zložke /
du -a / | d
du -a -h / | sort -r -n | head -n 1 >> space.txt 	# najde všetky subory (-human readable)v / následne ich podľa veľkosti(-n) zoradí zozadu (-r)
													#a následne head vypíše prvý riadok (- n 1)
tar -xf <file>#
 -v --verbose #zobrazí text o priebehu
 
 
mysql - prihlásenie do databáze
SHOW DATABASES - zobrazí vytvorené databázy

Vytorenie aliasu
alias nazovAlias='príkaz akýkoľvek'
vytvoriť (touch) zložku .bash_aliases v /home. Následne si otvoriť nano .bash_aliases a do nej zapísať napr.:
alias getdate='date | tee fulldate.txt | cut --delimiter=" " --fields=1 | tee shortdate.txt | xargs echo hello'

wildcards
	* - vssetko
	? - zastupený jeden znak
	[1,2,3] - zastupené všetko co je vramci [], len jeden znak
	file[1,2][a,b,c] -
		file[1-5].txt -  nájde file1.txt, file2.txt... file5
		file[A-Z]
	
Brace expansion #vytvorí všetko čo je vrámci zátvoriek
mkdir {jan,feb,man}_{2017..2022} #vytvorí zložky jan2017,feb2017,mar2017 .. mar2022
touch {jan,feb,mar}_{2017..2019}/file{1..100} #každej zložke vytvorí  file1-100

rmdir #vymaže priečinok ktorý je prázdny
rm -i #pýta sa na to či vymazať -r vymaže všetko aj so zložkami

cp <co chceš kopírovať> .. <Kam to chceš kopírovať> # s možnosťou -r skopíruje celý obsah spolu s priečinikom 
mv <oldfile> <newfile>  #premenuje old na new
	mv oldfolder/* . # presuň obsah z oldfolder do current adresára
	mv oldfolder/ ~/destination # presunie celý priečinok do priečinku v home/destination
	mv destina/copy_me/ ./jackopt # vezme zložku copy_me/ presunie ju do current priečinku a premenuje ju na jackopt

TEXT EDITOR NANO	
nano #text editor
 # ^ - ctrl
 # M - alt
 sudo nano /etc/nanorc # zmena nano nastavení 

who #príkaz na zistenie, kto je prihlásený
w  #príkaz na zistenie, kto je prihlásený a kto čo robí

sudo apt install locate mlocate # inštalácia locate/mlocate 
 
locate -i *.conf #lokalizeuje súbory, bez ohľadu na veľké a malé písmená, ktér majú koncovku .conf
locate -S #zobrazí štatistiku nejakej databázy
locate -e #skontrouluje či existuje nejaký súbor
locate --follow --existing #pomáha sa vyvarovať chybám a filtruje len existujúce súbory, ak nieje aktualizovaná databáze

sudo updatedb #Aktualizácia databázy 

FIND

find  #príkaz na hľadanie
find . -maxdepth 1 #nájdi všetko v aktuálnom priečinku ale maximálnu hlbku 1
find .  -type f #v aktuálnom priečinku nájdi všetky priečinky -type f (file), -type d (directory)
find  /home -type f -name '*.tar' # nájdi v /home všetky súbor s .tar v názve, ak chceš nájsť * musíš vyescapovať \ (spätné lomnítko)
find . -iname "4.TXT" #nájde podľa mena 4.txt v celej štuktúre od aktuálnej lokácie, NON-CASE SENSITIVE (je jedno čí su veľké alebo malé písmena)
find / -type f -size +100k #v / vyhľadaj všetky súbory, ktoré sú väčšie ako 100kB; 
# + znamená väčší; - menší
find / -maxdepth 4 -size +1M -type f -exec  ls {}  -lh \;
find / -type f -size -100k -o -size +5M | wc -l #zobrazí počet nájdených riadkov, pre súbory menšie ako 100kb alebo (-o) väčšie ako 5Mb
	wc word count #slúži na počítanie 
find / -maxdepth 3  -type f -size +100k -size  +5M -exec cp {} ~/copyHere/ \; #nájde všetky súbory väčšie ako 100kb a väčšie ako 5Mb, a všetky {} skopíruje -exec do copyHere/ 
find / -maxdepth 3  -type f -size +100k -size  +5M -ok cp {} ~/copyHere/ \; #nájde všetky súbory väčšie ako 100kb a väčšie ako 5Mb, a všetky {} skopíruje -ok do copyHere/, ale opýta sa či chceš kopírovať
find /etc -type d > /etc.txt #nájde priečinky v /etc a zapíše ich do /etc.txt


touch haystack/folder$(shuf -i 1-500 -n 1)/needle.txt 
#vytovrí v jednom z priečinkov súbor needle.txt 

Generovanie náhodných čísel
shuf -r -i 0-1000000 -n 100 > numbers.txt # -r môžu sa opakovať riadky, -i určím od - do; -n počet vypísaných riadkov

Sort
sort -r words.txt #zoradí slova v súbore words.txt zo zadu
sort -n numbers.txt #zoradí čísla numericky
ls -lh /etc/ | head -n 20  | sort -k 6M #zoradí prvých 20 riadkov v /etc/priečinku podľa dátumu; sort -k 6M - zoradí podľa -k stlpca (column), 6.v poradí podľa M-mesiac,
ls -lh /etc/ | head -n 20  | sort -k 5h #ak chcem zoradiť podľa veľkosti súboru, musím zadať možnosť h- human readable

lsblk #zobrazenie zariadení, ktoré sú pripojené k PC

#nájdenie uživateľov
sudo cat /etc/shadow
#nájdenie group
sudo cat /etc/group

file bash_script #zistím o aký typ súboru sa jedná

tar # kompresia - pozri Cheat sheet


_________________


getent passwd id  #is a Linux command that helps the user to get the entries in a number of important text files called databases

CRON - plánovač https://crontab.guru/
crontab -e #edit crontab
minúty 	hodiny	den v mesiaci	mesiac	den v týždni 
*/2 	* 				* 		*	 		* 		echo "Hello world" >> ~/Hello.txt #každé 2 minúty zapíš do súboru Hello.txt string Hello World
service cron restart #reštaruje cron aby začal od znova

cat /etc/os-release 
lsb_release -a
hostnamectl 
#zisti verziu os, architektúra CPU, Kernel, name 
lscpu 
cat /proc/cpuinfo
#informácie ohľadom architektúry CPU

uname #vypíše  systéemové info

systemd #nastavenie ktoré procesy sa spustia pri štarte systému

Grep hľadá nejaký pattern vrámci súboru, nehľadá priečinky
grep <options> pattern <file...> #hľadá "string" vrácmi súboru, prípadne vrácmi podpriečinkou -r
grep -l error *.log #Only show the names of files that contain a match

apt #advanced package tool
apt-cache search "web server" #nájde apku ktorá v sebe obsahuje "web server"
apt-cache show apache2 #ukáže podrobnosti ohľadom určitého balíčku
/var/lib/apt/lists  #dostupné balíčky

__________________________

Skript
nano - text editor 
#!/bin/bash-  - určujem v ktorom jazyku budem písať skript, a musí byť na začiatku každého skriptu, aby shell vedel, že sa jedná o skript.
#!Shebang musí byť na začiatku každého skriptu
Každý skript musí byť musíme následne nastaviť na execute chmod +x skript.sh
bash skript.sh #spustenie skriptu
na konci skriptu by nemal chýbať exit kód
	exit 0

















