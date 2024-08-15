====================Security====================
////Accounts
kube-apiserver pracuje s uctami

Mame 4 moznosti ako sa dostat na kubeapi:
	- static password file
	- Static token file
	- Certificates
	- Identity services (LDAP, Kerberos)
	
////Static password file
#najjednoduchsie, ulozime do .csv suboru 
password1, user1, userID, group1

#static password file ulozime do konfiguracneho suboru kubeapi a restartujeme api
/usr/local/bin/kube-apiserver

	--basic-auth-file=user-detail.csv

#--basic-auth-file=user-detail.csv mozeme tiez ulozit do manifest.yaml do spec.containers.command	

////Static token file
#podobne aok password file
token,user10,userID,group1
#zapiseme ho do konfigu 
--token-auth-file=user-token-detail.csv

password1,user1,u0001
password2,user2,u0002                                                                                                                                       password3,user3,u0003////

////TLS/SSL - Certifikaty 

Asymmetric encryption - pouziva Private a Public key (public lock)

na vygenerovanie Public Private keys na SSH spojenie - pre administraciu
#command
ssh-keygen

Vygeneruje nam 2 kluce, pomocou ktorych mozeme pristupovat na server - administratorske ucely

id_rsa
id_rsa.pub

-------Public key
#najdeme Public key
cat ~/.ssh/authorized_keys
tento kluc mozme kopirovat na viacero servrov
ak chceme aby na server pristupovala ina osoba, musiem jej tiez vygenerovat ssh kluc a pridat ho do ~/.ssh/authorized_keys

-------Public key na strane servru - aby mal uzivatel pristup
Na strane servru vygenerujeme public/private key

openssl genrsa -out my-privat.key 0123
openssl rsa -in my-bank.key -pubout > my

-------------SSH

na vygenerovanie Public Private keys na SSH spojenie so servrom si potrebujeme vygenerovať cez ssh-keygen 2 kluce, pomocou ktorych mozeme pristupovat na server - administratorske ucely. Public key umiestnime na server, ktorý chceme odomknúť private keyom.

id_rsa - nemôže byť zdieľaný a musí byť len u užívateľa na PC

id_rsa.pub - môže byť zdieľaný, ale otvorený môže byť len private keyom

//////Pripojenie cez SSH s private key

ssh -i id_rsa user1@server1

#najdeme Public key
cat ~/.ssh/authorized_keys
tento kluc mozme kopirovat na viacero servrov
ak chceme aby na server pristupovala ina osoba, musiem jej tiez vygenerovat ssh kluc a pridat ho do ~/.ssh/authorized_keys 

#Na strane servru vygenerujeme SSL public/private key

openssl genrsa -out my-privat.key 0123
openssl rsa -in my-bank.key -pubout > my

//////Pomenovanie cert/key
---Public key
*.crt, *.pem

---Private key
*.key, *-key.pem

----CA keys
ca.key - private key for CA

ca.crt - public key for CA

////////Generovanie TLS - OpenSSL
Vytvorenie klucov pre CA - certificate autohrity
#Generovanie private key :
openssl genrs -out ca.key 
#Ziadost na podpis:
openssl req - new -key ca.key -subj "/CN=KUBERNETES-CA" -ou  -> ca.csr
#Podpisanie cert:
 opensslx509 -req -in ca.csr -signkey ca.key -out ca.crt -> ca.crt
-------------------------
Vytvorenie klucov pre klientov - admin user a ostatne cert
#Generovanie private key :
openssl genrs -out admin.key 2048  -> admin.key

#Ziadost na podpis:
#v ziadosti musime uviest, ze sa jedna o group ADMIN (master:system), ktora ma admin privilegia
openssl req - new -key admin.key -subj "/CN=kube-admin/O=system:master" -out admin.csr -> admin.csr

#Podpisanie cert:
opensslx509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt-> admin.crt

////////Priklad zapisu cert do YAML
#Zapis certifikatov do kube-config.yaml

apiVersion: v1
clusters:
- cluster:
    certificate-authority: ca.crt
    server: https://kube-apiserver:6443
  name: kubernetes
kind: Config
users:
- name: kubernetes-admin
   user:
     client-certificate: admin.crt
     client-key: admin.key
----------------------

----Serverside cert

#ETCD server moze byt nasadeny ako cluster na viac servery (HA). Komuikaciu ETCD medzi roznymi servrami zabezpecuje bezpecnu komuukaciu peer certifikat.

========KUBE-APISERVER====
kubernetes
kubernetes.default
kubernetes.default.svc
kubernetes.default.svc.cluster.local
Vsetky tieto mena musia byt uvedene v certifikate, aby bolo mozne spojit sa

-----Generovanie kube-apiserver key

openssl genrs -out apiserver.key 2048 -----> apiserver.key
openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr ------> apiserver.csr

#APIserver ma alternativne mena, tieto je potrebne zadat do config filu do sekcie

[alt_names] -> openssl.cnf

-----Podpisanie cert
opensslx509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt-> apiserver.crt
#V kube-apiserver configu, musime urcite aj to kde sa nachadzaju certifikaty pre etcd, kebelet, ca/tls cert

-----------Generovanie cert pre kubectl Nodes (server cert) - kubelet

#pre každy node musime zvlast upravit kubelet-config.yaml a doplniť tam informacie o ca.pem

kubelet-config.yaml:

authentification:
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
tlsCertFile: "/var/lib/kubelet/kubelet-node1.crt"
tlsPrivateKeyFile: "/var/lib/kubelet/kubelet-node1.key"

---------Detaily certifikatu

//////APISERVER configfile

#v configfile najdeme cesty k vsetkym certifikatom
cat /etc/kubernetes/manifests/kube-apiserver.yaml

#detaily jednotlivych certfikatov dekodujeme a zobrazime pomocou
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout


===Service logs - hardway
#zobrazenie logov, ak sme konfigurovali cluster od 0
journalctl -u etcd.service -l

===Service logs - by kubeadm
#zobrazenie logov ak sme na konfiguraciu pouzili kubeadm - vsetko je spustene ako POD
kubectl logs etcd-master

!!!!! v pripade, ze spadne kubectl, musime logy prehliadat o level nizsie v docker logs !!!!

Priklady na vyhladavanie v CERT
-----Identify the ETCD Server Certificate used to host ETCD server
#Look for cert-file option in the file /etc/kubernetes/manifests/etcd.yaml.
-----Identify the ETCD Server CA Root Certificate used to serve ETCD Server.
Look for CA Certificate (trusted-ca-file) in file /etc/kubernetes/manifests/etcd.yaml.
-----What is the Common Name (CN) configured on the Kube API Server Certificate?
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text and look for Subject CN.
-----What is the Common Name (CN) configured on the ETCD Server certificate?
openssl x509 -in /etc/kubernetes/pki/etcd/server.crt -text and look for Subject CN.

======Certificates signing request CSR====
Vsetky operacie zodpovedne za certifikaty su robene Controller Managerom

#automatizuje vytvaranie certifikatov
CertificateSigningRequest OBJECT .CSR

////Postup
#user vygeneruje key
openssl genrsa -out jane.key 2048
#z vytvorime yaml subor
////jane-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata: 
	name: jane
spec:
	expirationSeconds: 600 #second
	usages:
	- digital signature
	- key encipherment
	- server auth
	reguest: #doo tohto pola specifikujem signing request
				#musime ho tam ale vlozit cez encoding base64 nie ako plain text  
				
		vystup z prikazu cat jane.csr | base64

#spustsime CSR 
kubectl apply -f akshay-csr.yaml


------------------
#vygeneruje signing req s menom certu a posle ziadost adminovy
openssl req -new -key jane.key -subj "/CN=jane" -out jane.csr
#administrator ziadost prevezme a vytvori CertificateSigningRequest objekt
 

	
/// Prikazy 
#na zobrazenie signing req
kubectl get csr
#schvalenie signing request
kubectl certificate approve jane
#zobrazenie certifikatu v yaml formate 
#detail grupy do ktoreho cert spada
kubectl get csr jane -o yaml #certikata je zakodvany
#cert dekodujeme 
echo "text certfikatu" | base64 --decode


------ConfigFile------
#specifikujeme v nom udaje o certifikatoch
#je umiestneny v $HOME/.kube/config
///////YAML FILE
apiVersion: v1
kind: Config
current-context: dev-user@google #specifikuje ktory ma byt predvoleny
clusters: 
- name: my-kube-playground
  cluster:
    certificate-authority: ca.crt #lepsie pouzit celu cestu k certifikatom
    #mozeme pouzit aj obsah konkretneho crt pouzitim base64
    certificate-authority-data: vystup z: cat ca.crt | base64 
    server: https://my-kube-playground:6443
- name: development
 . . . #skrite hodnoty
- name: production
 . . . 
- name: google
 . . . 

contexts:
- name: my-kube-admin@my-kube-playground
  context:
    cluster: my-kube-admin 
    user: my-kube-admin
    namespace: finance
- name: dev-user@google
. . .
- name: prod-user@produciton
. . .

users:
- name: my-kube-admin
  user:
    client-certificate: admin.crt
    client-key: admin.key
- name: admin
. . .
- name: dev-user
. . .
- name: prod-user
. . .

///////Prikazy 
kubectl config view #zobrazenie momentalneho config filu, ake nespecifikujeme aky, tak pouzije predvoleny z $HOME/.kube/config
kubectl config view --kubeconfig=my-custom-file #specifikujem konkretny configfile
#ak necheme pouzivat --kubeconfig tak ziadany configfile musime nakopirovat do /root/.kube/config
kubectl config use-context prod-user@production #uprava configfilu

====================ServiceAccount====================
2 druhy:
---User Account
	pouzivane ludmi - Admin, Developer, eetc. 

 ///Prikazy
 
-Service account
	pouzivane strojmi (robotmi)  - Monitoring /prometheus/, Jenkins, etc. 
Ak sa vytvori SA tak spolu s nim sa vytvori aj token (bez platnosti), ktory sluzi na autentifikaciu s KUBEAPI
Token je ulozeny ako Secret object ako <NazovSA-token-kbbdm>
Secret object je preojeny so SA
Pre kazdy NS existuje defaultny SA. Ak sa vytvori novy pod, defaultny SA je automaticky prideleny PODu

V detailu podu najdeme jaky token bol v pode pouzity a kde je ulozeny (Mounts):
k exec -it <nazov_podu> -- ls /cesta/z/detaily/podu/mounts
vystup su 3 subory ca.crt, token, namespace

Ak v deploy zmenim SA, tak deployment sa postara o vytvorenie novych podov. Ak SA zmenim u Podu, tak ten sa novy nevytovri a je potrebne ho zmazat.
Ak nechcem aby sa do podu automaticky zapisal token musim zapisat do pod=definition.yaml ------> spec.automountServiceAccountToken(false)

Od verzie 1.22 sa o vytvorenie tokenov stara TokenRequestAPI a token je vlozeny ako projected volume
Od verzie 1.24 je nutne pre kazdy SA vytvorit token (ma platnost)
Ak chceme vytvorit token po staru (bez platnosti) tak v secret-definiton.yaml musime uviest do ----> metadata.annotations.kubernetes.io/service-account.name(nazovSA)

///Prikazy
#vytvorenie SA
k create serviceaccount <nazov-SA>
#zobrazenie Secret object SO
k describe secret  <NazovSA-token-kbbdm>
#vytvvorenie tokenu pre SA
k create token <nazov SA>
#Run the following command to use the newly created service account:
kubectl set serviceaccount deploy/web-dashboard dashboard-sa

====================Autorization====================
-------RBAC

////Prikazy
kubectl get roles #zisti kolko ROLE existuje v defautl NS
kubectl get rolebindings
---------
k auth can-i create deployments
k auth can-i deletenodes #zistim ake mam opravenia 
#ak som admin mozem oskusat opravnenia bez toho aby som sa prihlasil
k auth can-i create deployments --as dev-user
#zistime ci dev-user ma moznost create deployment v namespace test
k auth can-i create deployments --as dev-user --namespace test
#zistme ci user dev-user ma moznost get pody
kubectl get pods --as dev-user 

--------- Zistenie aku autorizaiu ma API server
k describe --namespace kube-system pod apiserver #and look for --authorization-mode

---------Vytvranie role\rolebindings
#mozme vytvorit priamo cez create alebo si vytovrime svoj vlastny yaml subor imperative/declarativ
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-example
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-example

#role
kubectl create role developer --namespace=default --verb=list,create,delete --resource=pods
#binding role 
kubectl create rolebinding dev-user-binding --namespace=default --role=developer --user=dev-user


====================Private repository====================
Na to aby sme vytvorili 

///Prikazy
#prihlasenie sa do private-registry
docker login private-registry.io
#spustenie msc z private repository
docker run private-registry.io/apps/internall-app
			       |             |      |
				registry     library  image
