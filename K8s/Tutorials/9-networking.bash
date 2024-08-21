================Switching & Routning====================
Switch - prepaja 2 zariadenia vramci jednej siete
Router - prepaja ine siete pomocou (default gateway)

#existujce routing nastavenia
route
#nastavenie routovania siete cez gateway
ip route add 192.168.2.0/24 via 192.168.1.1 
			#rozsah IP adries     #getaway
#tieto nastavenia sa zmazu po restarte
#ak ich chceme zachovat musiem to zapisat do 
/etc/network-interfaces
			
#pouzi DG na vsetky nezname 
ip route add default via 192.168.1.1  # rovnake ako default je 0.0.0.0

#list and modify interfaces
ip link
#zobraz adresy priradnee k urcitemu interfacu
ip addr

#zobraz routing tabulku
ip route
route

#skontroluj ci je zapnuty ip forwarding
cat /proc/sys/net/ipv4/ip_forward

================DNS================
#ak chceme priradit ip adresu nejake meno, zapiseme to do
#mozeme tam zapisat kolko chceme 
/etc/hosts

192.168.1.10 db
#toto riesenie je zlozite, lebo musime pridavat na kzdy server zvlast
______________________________________________

#pouzivame DNS server
Vsetky servre odkzujeme na DNS server aby pozrel na nazvy/ipadresy
Na vsetkych servroch nastavime nas DNS server v
/etc/resolve.conf
nameOfServer ipadresa_dns_servru

server sa vzdy najprv pozera do /etc/hosts, ak nenajde adresu tam, tak sa diva na DNS server

----PRikazy
nslookup - hlada len na DNS servre
dig - detailnejsie info ohladom DNS

-----Nastroje na DNS
CoreDNS


