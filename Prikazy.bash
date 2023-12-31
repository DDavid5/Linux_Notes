CTRL+C - zrušenie vstupu
CTRL+D - odhlásenie

apropos - vyhľadaj kľúčove slovo

====================Skrolovanie ====================
D, U používam na skrolovanie v manuali, keď hľadám cez /

====================File system====================
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
systemctl status/start/stop...  #test status apache2,sql,php... 

sudo !! #predošlý príkaz s root opravnením

man a následne príkaz /dir  -- hľadám zadaný výraz - D, U presúvam medzi hľadným výrazom

which - príkaz ktorý zisti cestu k executable files
sudo su - #root

====================Inštalovanie softvéru====================

chmod u+x <file> # urobí súbor pre user executable X  
chown - Change the owner and/or group of each FILE to OWNER and/or GROUP.
read číta zadanie z klávesnice read name
 
====================Prikazy na čítanie súborov====================
cat
tac - číta súbor(riadky) v opačnom poradí ako cat (otočí to hore nohami) (vertikálne - stlpcove)
rev - otočí obsah každého riadku (horizontálne, riadkové)
less - podobne ako cat ale môžeme skrolovať od hora a postupne prehliadať, zatvorím to písmenom Q.
head - zobrazí len prvých 10 riadkov, -n určí koľko riadkov chceme zobraziť  
tail - opak head
cut - oreže data

====================Redirection==================== 
- ak urobíme redirection už nieje možné PIPovať
0> output
0< input
2> error

====================
xargs - ak command neakceptuje STDIN, tak použiješ xargs, zmení input na 
tee - križovatka - napr uloží do súboru a vypíše v konzole napr:
date | tee fulldate.txt | cut -d " " -f  - t.j. do súboru uloží plný dátum a na konzole vypíše len prvý stlpec
touch vytvorí súbor
mkdir - vytvorí zložku
	mkdir -p /z1/z2 #ak cesta neexistuje tak vytvorí rodicovské 

====================Podmienka====================
if [[ $beast || $neco == 1]]
fi # ukončuje podmienku
case 
	1)
	;;
	2)
	;;
esac # ukončuje case
====================Usefull command====================
who #príkaz na zistenie, kto je prihlásený
w  #príkaz na zistenie, kto je prihlásený a kto čo robí
file bash_script #zistím o aký typ súboru sa jedná
sudo apt install locate mlocate # inštalácia locate/mlocate 
lsblk #zobrazenie zariadení, ktoré sú pripojené k PC

====================Automatic upgrade - Unattended upgrades =============
sudo apt install unattended-upgrades #softvér na zistenie aktualizácií
sudo dpkg-reconfigure --priority=low unattended-upgrades  #spustenie
apt-get 
====================Disk management====================
df #discfree skontroluje miesto na disku
du -a / #zisti využitie na disku pre všetky súbory v zložke /
du -a / | d
du -a -h / | sort -r -n | head -n 1 >> space.txt 	# najde všetky subory (-human readable)v / následne ich podľa veľkosti(-n) zoradí zozadu (-r)
													#a následne head vypíše prvý riadok (- n 1)
====================TAR - tape archive====================
tar # kompresia - pozri Cheat sheet		
tar -xf <file># x extrahuje súbur f- povinný, za f musí následovať názov tar súboru
	-v --verbose #zobrazí text o priebehu
	-cf <file> #vytovrí archív z nejakým názvom f
 
 
mysql - prihlásenie do databáze
SHOW DATABASES - zobrazí vytvorené databázy

====================Vytorenie aliasu====================
alias nazovAlias='príkaz akýkoľvek'
vytvoriť (touch) zložku .bash_aliases v /home. Následne si otvoriť nano .bash_aliases a do nej zapísať napr.:
alias getdate='date | tee fulldate.txt | cut --delimiter=" " --fields=1 | tee shortdate.txt | xargs echo hello'
#permanenty alias vytovrime podobne ako temporary ale musime ho ulozit do ~/.bashrc

====================Wildcards====================
	* - vssetko
	? - zastupený jeden znak
	[1,2,3] - zastupené všetko co je vramci [], len jeden znak
	file[1,2][a,b,c] -
		file[1-5].txt -  nájde file1.txt, file2.txt... file5
		file[A-Z]
	

====================TEXT EDITOR NANO====================	
nano #text editor
 # ^ - ctrl
 # M - alt
 # ALT + A markovaci mod
 sudo nano /etc/nanorc # zmena nano nastavení 

====================Locate====================
locate -i *.conf #lokalizeuje súbory, bez ohľadu na veľké a malé písmená, ktér majú koncovku .conf
locate -S #zobrazí štatistiku nejakej databázy
locate -e #skontrouluje či existuje nejaký súbor
locate --follow --existing #pomáha sa vyvarovať chybám a filtruje len existujúce súbory, ak nieje aktualizovaná databáze

sudo updatedb #Aktualizácia databázy 

====================FIND príkaz na hľadanie====================

find . -maxdepth 1 #nájdi všetko v aktuálnom priečinku ale maximálnu hlbku 1
find .  -type f #v aktuálnom priečinku nájdi všetky priečinky -type f (file), -type d (directory)
find  /home -type f -name '*.tar' # nájdi v /home všetky súbor s .tar v názve, ak chceš nájsť * musíš vyescapovať \ (spätné lomnítko)
find . -iname "4.TXT" #nájde podľa me.na 4.txt v celej štuktúre od aktuálnej lokácie, NON-CASE SENSITIVE (je jedno čí su veľké alebo malé písmena)
find / -type f -size +100k #v / vyhľadaj všetky súbory, ktoré sú väčšie ako 100kB; 
# + znamená väčší; - menší
find / -maxdepth 4 -size +1M -type f -exec  ls {}  -lh \;
find / -type f -size -100k -o -size +5M | wc -l #zobrazí počet nájdených riadkov, pre súbory menšie ako 100kb alebo (-o) väčšie ako 5Mb
	wc word count #slúži na počítanie 
find / -maxdepth 3  -type f -size +100k -size  +5M -exec cp {} ~/copyHere/ \; #nájde všetky súbory väčšie ako 100kb a väčšie ako 5Mb, a všetky {} skopíruje -exec do copyHere/ 
find / -maxdepth 3  -type f -size +100k -size  +5M -ok cp {} ~/copyHere/ \; #nájde všetky súbory väčšie ako 100kb a väčšie ako 5Mb, a všetky {} skopíruje -ok do copyHere/, ale opýta sa či chceš kopírovať
find /etc -type d > /etc.txt #nájde priečinky v /etc a zapíše ich do /etc.txt


===================Generovanie náhodných čísel====================
shuf -r -i 0-1000000 -n 100 > numbers.txt # -r môžu sa opakovať riadky, -i určím od - do; -n počet vypísaných riadkov
touch haystack/folder$(shuf -i 1-500 -n 1)/needle.txt 
#vytovrí v jednom z priečinkov súbor needle.txt

====================Sort====================
sort -r words.txt #zoradí slova v súbore words.txt zo zadu
sort -n numbers.txt #zoradí čísla numericky
ls -lh /etc/ | head -n 20  | sort -k 6M #zoradí prvých 20 riadkov v /etc/priečinku podľa dátumu; sort -k 6M - zoradí podľa -k stlpca (column), 6.v poradí podľa M-mesiac,
ls -lh /etc/ | head -n 20  | sort -k 5h #ak chcem zoradiť podľa veľkosti súboru, musím zadať možnosť h- human readable

=====================

getent passwd id  #is a Linux command that helps the user to get the entries in a number of important text files called databases

====================CRON - plánovač https://crontab.guru/====================
crontab -e #edit crontab
minúty 	hodiny	den v mesiaci	mesiac	den v týždni 
*/2 	* 				* 		*	 		* 		echo "Hello world" >> ~/Hello.txt #každé 2 minúty zapíš do súboru Hello.txt string Hello World
service cron restart #reštaruje cron aby začal od znova

====================
cat /etc/os-release 
lsb_release -a
hostnamectl 
#zisti verziu os, architektúra CPU, Kernel, name 
lscpu 
cat /proc/cpuinfo
#informácie ohľadom architektúry CPU

uname #vypíše  systéemové info

systemd #nastavenie ktoré procesy sa spustia pri štarte systému
====================Grep ====================
hľadá nejaký pattern vrámci súboru, nehľadá priečinky
grep <options> pattern <file...> #hľadá "string" vrácmi súboru, prípadne vrácmi podpriečinkou -r
grep -l error *.log #Only show the names of files that contain a match
grep --color "najdi tento text" vsubore.txt #najdi text bude farebny
grep -r "Linux" #najdi Linux v priecinku a jeho podpriecinkoch
grep -w "Najdi presnu zhodu"

grep -A 4 -B 4 ens3  #zobrazi 4 riadky pred a 4 riadky za najdenou zhodou
====================APT a repozitare====================
Všetky príkazy sú v /usr/bin/

apt #advanced package tool
apt-cache search "web server" #nájde apku ktorá v sebe obsahuje "web server"
apt-cache show apache2 #ukáže podrobnosti ohľadom určitého balíčku
/var/lib/apt/lists  #dostupné balíčky
apt-cache policy <package name> #zisti z ktoreho repo bol balicek nainstalovany
tail -f /var/log/dpkg.log #subor logov, ktore ukazuju, kedy boli jednotlive balicky nainstalovane
grep remove /var/log/dpkg.log #zobrazi zmazane apt
less /var/log/apt/history.log #zobrazi historiu apt

====================Zobrazenie uzivatelov[group]====================
adduser uzivatel sudo #prida uzivatela do sudo gruppy
cat /etc/passwd
#nájdenie uživateľov
sudo cat /etc/shadow
#nájdenie group
sudo cat /etc/group
cat etc/group - nastavenia jednotlivej grupy
======================== User management/permission ========================
sudo ---> execute command as a different user (root usually)
su ---> switch user. Request appropriate user credentials via PAM, then switche
s to that user. Shell is then executed
useradd ---> create new or manipulate old user
userdel ---> deletes user account or related files
usermod ---> manipulate with user account
sudo usermod -a -G newgroup username ---> add user to the group
addgroup ---> create group
delgroup ---> remove group
passwd ---> change user password
chmod ---> changes permission of a file or directory
chown <owner>:<group> ---> change owner and group of a file or directory



====================VARIABLES and Shell expansions====================

Parameter - hocijaká entita, ktorá ukladá hodnotu
Premenná - parameter, ktorého hodnou je možné meniť

Vytvorenie premennej 
student="Sarah" #zápis premennej musí byť bez medzier
Vyhľada hodnotu premennej ${student}

Simple Syntax: $parameter
Advanced Syntax: ${parameter}

====================PARAMETER EXPANSION TRICKS====================

1 ${parameter^}
Convert the first character of the parameter to uppercase
2${parameter^^} # ^caret symbol
Convert all characters of the parameter to uppercase
3${parameter,,}
Convert all characters of the parameter to lowercase
4${#parameter}
Display how many characters the variable’s value contains
5${parameter : offset : length}
The shell will expand the value of the parameter starting at
character number defined by “offset” and expand up to a
length of “length”
#príklad 
numbers=0123456789
echo ${numbers:1:5}
#zobrazí sa 
12345
je možné dať aj negatívny offset ale musí byť s medzerou
echo ${numbers: -3:2}
#zobrazí sa
78

====================SHELL VARIABLES====================
Sú vždy písané veľkými písmenami

Bash shell variables 
https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html#Bash-Variables
Bourne Shell variables 
https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Variables.html#Bourne-Shell-Variables

$PATH premenná hovorí shellu, kde má hľadať spustiteľné súbory.

V zložke ~/home/[uzivatel]/.profile napíšeme pomocou nano cestu, kde systém môže hľadať spustitelné súboru (skripty)
	Do .profile napíšeme cestu napr. export PATH="$PATH:$HOME/bash_course/scripts"
	
	Pomoocu príkazu source source ~/.profile obnovíme súbor .profile, pretože tento súbor sa obnvouje len s reštartom Bashu
	
	Môžeme pridať pričinky do nášej PATH premennej tým, že zmeníme súbor .PATH

$HOME - premenná určená na uloženie absolútnej cesty do domovského priečinku užívateľa
$USER - premenná obsauje meno aktuálneho užívateľa
$HOSTNAME - meno aktuálneho počítača
$HOSTTYPE - typ architekúry procesora, na ktorom beží počítač
$PS1 - reťazec výzvy zobrazený v termináli pred každým príkazom
	PS1="$: " 
	na začiatku každého riadku sa nám bude zobrazovať "$: "
	Ak to chceme resetnúť tak source ~/.bashrc
	Odkaz na WEB kde môžem meniť začiatok riadku PS1
	https://ezprompt.net/
	
====================Command Substitution====================
je funkcia, pomocou ktorej môžeme dať príkaz shellu, aby nahradil skutočnú hodnotu výrazu. 
Je mozne jeho vystup ulozit do premennej, takze vysledok je mozne pouzit neskor 

SYNTAX
time=$(date +%H:%m:%S)
echo "Hello $USER, the time right now is $time"
priklad
tar -cvf ~/bash_course/my_backup_"$(date +%d-%m-%Y_%H-%M-%S)".tar ~/* 2>/dev/null
#vystup je
Hello pi, the time right now is 14:09:42


====================Arithmetic EXPANSION====================

Syntax for Arithmetic Expansion
#vie pracovat len s celymi cislami, nevie pracovat s desatinami 
$(( expression ))
x=4
y=2
echo $(( $x + $y ))
echo $(( x - y ))
echo $(( x / y ))
echo $(( x * y ))
#mozeme to pisat bez $, usetri nam to kusok casu

na pocitanie desatin pouzivame bc (basic calculator) command
echo "scale=10; 5/3"| bc #pomocou scale nastavime pocet desatinych miest, do prikazu bc je mozne pipovat
mocnina sa zapisuje inac v bc ako obycane 5^2=25
 
====================Tilde expansion ~ ====================
jednoduchy pristup k domovskemu priecinku a k prieecinku inych uzivatelov
Jednoduche prepinanie medzi sucasnym a predoslym priecinkom

Ak chceme najst domaci prienetcinok nejakeho uzivatela
~uzivatel, je to vlastne $HOME premmenna
$PWD - premenna v ktorej je ulozene nasa momentalna cesta (current directory)
	~+ je to rovnako ako $PWD
$OLDPWD - ulozena moja predosla pracovna cesta
	~- je to rovnako ako $OLDPWD
	
==================== Brace expansion vytvorí všetko čo je vrámci zátvoriek {} ====================
mkdir {jan,feb,man}_{2017..2022} #vytvorí zložky jan2017,feb2017,mar2017 .. mar2022
touch {jan,feb,mar}_{2017..2019}/file{1..100} #každej zložke vytvorí  file1-100

rmdir #vymaže priečinok ktorý je prázdny
rm -ir #pýta sa na to či vymazať -r vymaže všetko aj so zložkami

cp <co chceš kopírovať> .. <Kam to chceš kopírovať> # s možnosťou -r skopíruje celý obsah spolu s priečinikom 
mv <oldfile> <newfile>  #premenuje old na new
	mv oldfolder/* . # presuň obsah z oldfolder do current adresára
	mv oldfolder/ ~/destination # presunie celý priečinok do priečinku v home/destination
	mv destina/copy_me/ ./jackopt # vezme zložku copy_me/ presunie ju do current priečinku a premenuje ju na jackopt
	
====================PORTs====================
cat /etc/services
lsof #zobrazi otvorene porty
netstat #zobrazi vsetky porty
		-t: Display all TCP ports
		-u: Display all UDP ports
		-I: providing listening server sockets
		-P: Show PID and names of sockets programs
		-n: It is executed so that the names are not resolved
		grep LISTEN: Filter the output to display open ports in LISTEN status using the grep command
sudo netstat -tulpn | grep LISTEN
ss -l option: show listening ports
	-lt option: show listening TCP ports
	-tul option: Access a list of TCP and UDP listening ports
	-n option: to access the listening port of the specified service
nmap -sT -O localhost #prehladavanie a identifikacia otovrenych portov na local host

====================Firewall====================
https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-debian-11-243261243130246d443771547031794d72784e6b36656d4a326e49732e
apt-get install ufw
sudo ufw show #ukaze ako nastavovat ufw
sudo ufw default deny incoming #zablokujeme prichadzajuce pripojenie
sudo ufw default allow outgoing #odblokujeme odch. pripojenie
sudo ufw allow ssh #povolit ssh pripojenie
sudo ufw allow 22 #povolit ssh pripojenie pomocou portu 22
sudo ufw status numbered # zistime ake porty sme povolili, ukaze nam to ciselne
sudo ufw disable #vypne firewall