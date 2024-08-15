====================KUBECTL{minicube)====================
https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ #postup na instalaciu

https://minikube.sigs.k8s.io/docs/start/ #minikube postup

https://kubernetes.io/docs/reference/kubectl/quick-reference/ #manual na kubectl prikazy

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" #instalacia kubectl

curl -LO "https://dl.k8s.io/release/$(curl -L -s ttps://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" #Download the kubectl checksum file , odhaluje chyby
minikube start --driver=docker #dolezite je si urcite aky engine bude pohanat minikube, je mozne si urcit docker, podman, VMware
kubectl version --client #over aku verziu klienta mas
minikube status # skontroluje ci vsetko je nastavene
cat /etc/os-release #zisti verziu OS

BEST PRACTICES
https://kubernetes.io/docs/reference/kubectl/conventions/

====================ETCD====================
ETCDCTL can interact with ETCD Server using 2 API versions - Version 2 and Version 3.  By default its set to use Version 2. Each version has different sets of commands.

For example ETCDCTL version 2 supports the following commands:

etcdctl backup
etcdctl cluster-health
etcdctl mk
etcdctl mkdir
etcdctl set


Whereas the commands are different in version 3

etcdctl snapshot save 
etcdctl endpoint health
etcdctl get
etcdctl put

To set the right version of API set the environment variable ETCDCTL_API command

export ETCDCTL_API=3

====================api-server====================
Primarny riadiaci komponent. Ak spustim kubectl tak ten prikaz ide cez API-SERVER. API-SERVER rozpozna poziadavku a posle do etcd. etcd odpovie naspat cez api uzivatelovi.
#zobrazim api server
kubectl get pods -n kube-system 
#view api-server options in kubeadm 
cat /etc/kubernetes/manifests/kube-apiserver.yaml 
#view api-server options in non kubeadm
cat /etc/systemd/system/kube/apiserver.service
#beziace procesy spojene s api-server
ps -aux | grep kube-apiserver


====================kube-controller-manager====================
Zodpovedny za ovladanie ostatnych controllerov v K8
Je na master node
controller - proces ktory, monitoruje status komponentov vramci systemu 
	Node-controller - kontroluje heartbeat nodov, ak tam nieje heartbeat tak iny controller nieco vykona

#zobrazenie nastaveni kubectl manager
kube-controller-manager.serice 
#zobrazi nastavenia kube-controller-manager - s kubeadm
cat /etc/kubernetes/manifests/kube-controller-manager.yaml
#zobrazi nastavenia kube-controller-manager - bez kubeadm
cat /etc/systemd/system/kube-controller-manager.serice
#Zobrazi ci je controller zapnutu - 1 pod vramci kazdeho master nodu
kubectl get pods -n kube-system #
#zobrazi procesy spojene s controller
ps -aux | grep kube-controller-manager

====================kube scheduler====================
Rozhoduje ktory pod pojde na aky node, sam ich ale nevytvori. Za to je zodpovedny kubelet
#zobrazi nastavenia pre scheduler ake pouzivame kubeadm
cat /etc/kubernetes/manifests/kube-scheduler.yaml

#procesy ktore suvsia so scheduler
ps -aux | grep kube-scheduler

====================kubelet====================
kubelet - vytvara pody/kontajnere
		- kontroluje stavy podov
		- ak dostane signal z kube-api, ze ma vytvorit kontajner, tak kubelet a poziada kontajner engine aby spustil image

kubelet je potrebne vzdy instalovat manualne

#zobrazenie procesov spojenych s kubelet
ps -aux | grep kubelet
	

====================kube-proxy====================
kube-proxy 	- zabezpecuje aby service boli dostupne na potrebnych nodoch  - podla podmienok - lejblov
			- bezi na kazdom node vramci clustru

#Zobrazi ci je kube-proxy zapnuty - musi byt vyvoreny pod 
kubectl get pods -n kube-system 	
kubectl get deamonset -n kube-system
		
#zobrazi nastavenia pre scheduler ake pouzivame kubeadm
cat /etc/kubernetes/manifests/kube-scheduler.yaml

====================IMPERATIVE====================
Tento pristup je v podstate step-by-step pristup. 
1. vytvor VM
2. instaluj NGINX
3. zmen config file a pouzi port 8080
...
///////IMPERATIVE command
#vsetky tieto prikazy je mozne pouzit a su jednoduche, ale ked sa spustia zmiznu a je mozne vidiet ich historiu len u uzivatela, ktory ich spustil 
kubectl run --image nginx nginx
kubectl create deployment --image=nginx nginx
kubectl expose deployment nginx --port 80
kubectl edit deployment nginx
kubectl scale deployment nginx --replicas=5
kubectl set image deployment nginx nginx=nginx:1.18

///////IMPERATIVE object config files
#uzivatel vidi, co sa deje po po spusteni, prehladnejsie ako pisat priamo immperative command
kubectl create -f neco.yaml
kubectl replace -f nginx.yaml
kubectl delete -f nginx.yaml

#otovri nam subor uz vyvoreneho objektu, ktory je ulozeny v pameti K8s a mozeme ho priamo upravovat pre nase potreby 
#zmeny, ktore urobim cez edit niesu v pamati nikde zaznamenane a mozu byt odlisne od yaml suboru, takze ak sa znovu spusti yaml subor, tak spusti sa nam so starymi vlastnostami
kubectl edit deployment nginx 

#lepsie je najprv zmenit yaml subor a nasledne spusti
#tato zmena je zaznamena a dohhladatelna v historii
kubectl replace -f nginx.yaml


====================DECLARATIVE====================
Tento pristup definuje co za vysledok chceme ale SW to urobi za nas
IaC - orchestration tool Ansible, Terraform, Chef, Pupet

///////create command
#vyvorti object ale len v tom pripade ze objekt uz neexistuje
kubectl apply -f nginx.yaml
#mozeme specifikovat priamu cestu, kde apply najde zoznam toho co sa ma spustit
kubectl apply -f /path/to/config-files

///////update commad
#v declarative pristupe ak zmenime YAML subor, tak znovu spustime a ten rozpozna, ze uz objekt existuje a len ho aktualizuje podla najnovsich vlastnosti
kubectl apply -f nginx.yaml

///////Pri tejto metode sa nam z naseho LOCAL FILE.yaml ulozia data do LIVE OBJECT CONFIG FILE, ktory je ulozeny priamo v K8s. LOF ma pod METADATA->annotations->kubectl.kubenetes.io/last-applied/configuration ulozene LAST APPLIED CONFIGURATION (vo formate JSON). LAC sa porovnavaju s datami v LOCALFILE a s LOF. Ak nastane zmena v LOCALFILE, LAC porovna data s LOF. Ak to neni = , tak LOF subor sa prepise datami z LOCALFILE. LAC nasledne doplnit JSON spravnymi informaciami.
