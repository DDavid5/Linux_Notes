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

================Network Namespaces================
-----Postup na nastavenie siete - jedna linka po druhej - zlozite -> pouzivame BRIDGE
#potrebne vytvorit NS
#vytvor novy network NS
ip netns add red

#vytvorenie virtualnych liniek, typu = virtual ethernet = pipe
ip link add <veth_red> type veth peer name <veth_blue> 
#odkaz na man page 
https://man7.org/linux/man-pages/man8/ip-link.8.html

 #pripoj virtulny vystup (veth_red) k NS red
 ip link set veth_red netns red

 #prirad IP adresu linke veth_red
 #-n namespace, dev veth_red = zariadenie, na ktore chceme priradit danu IP 
 ip -n red addr add 192.168.15.1 dev veth_red

 #vsetky linky je potrebne zapnut
 ip -n red link set veth_red up

----- vytvorenie Bridge (virtual switch)
#vyvorime si pripojenie typu brige
ip link add v-net-0 type brige

#brigde si spustime
ip link set dev v-net-0 up

#vytvorime interface pre bridge - spojime NS s bridge
ip link add veth-red type veth veth peer name veth-red-br

#spojenie linky s NS
ip link set veth-red netns red
#spojenie linky s bridge - master
ip link set veth-red-br master v-net-0

#specifikuj IP adresy
ip -n red addr add 192.168.15.1 dev veth-red

#zapni linku 
ip -n red link set veth-red up

#host a NS su na inej sieti, preto potreujeme vytvorit konektivitu
ip addr add 192.168.15.5/24 dev v-net-0 #ip addresa brigdu
#teraz je mozne pingunut NS z hostu
#nieje mozne pingat z vonkajsieho sveta

#potreujeme hostovi urcit gateway, na ktore budu chodit dotazy na vsetky nezame siete -gateway 

- V ramci Bridgu musime mat nastaveny NAT, ktory sa bude chovat ako Gateway a bude posielat spravy do internetu
- 
---- NAT ----
#NAT mode will mask all network activity as if it came from your Host OS, although the VM can access external resources.
iptables -t nat -A POSTROUTING -s 192.168.15.0/24 -j MASQUERADE	

----Prikazy
#zobraz NS na hostu
ip netns
#zobraz interface na hostu
ip link

#spust prikaz ip link vo vnutri NS red
#Spustenie príkazu  v konkretnom NS siete
ip netns exec <meno NS> ip link
#alebo
ip -n <meno NS> link # -n pouzi v NS  <meno NS>

#ping na stroj v inom NS
ip netns exec red ping <ip adresa linky v inom NS>

#vymazanie virtualneho kabelu
ip -n <meno> link del <meno NS>

#ukaz adresu typu bridge
ip addr show type bridge

#ukaze routovacie adresy
ip route show 

#zistenie sietovych statistik / napr na ktorom porte bezi aka sluzba
netstat -nplt #n cisela hodnota IP adresy namiesto aliasu, -l listenig sockets, -t ukaz tcp 
netstat -anp | grep etcd
