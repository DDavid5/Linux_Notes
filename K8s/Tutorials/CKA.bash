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

====================Taints and Tolerations====================
Taint su na Nodoch
Tolerations su na Podoch

urcuje, ktory pod moze ist na ktory NODE. Neurcuje ale, ze POD musi byt prave len na tom konkretnom NODE - na to sluzi Node affinity


///////Taint
Taint effect - co sa stane s PODmi, ktore netoleuju taint
3 typy taint-effect:
	NoSchedule - pody nebudu umiestnene na NODE na ktorom je taint
	PreferNoSchedule - system sa snazi vyhnut umiestneniu podu na NODE s taint 
	NoExecute - nove pody nebudu umiestnene na NODY s taint, a existujuce pody budu odobrate z nodov
///////priklady
 #vseobecny zapis taintu na Node
kubectl taint node node-name key=vaue:taint-effect
#konkretny zapis taint
kubectl taint nodes node1 app=blue:NoSchedule
#prikaz, ktory ukaze Taint na master node
kubectl describe node kubemaster | grep Taint 
///////Tolereations
#zapis do yaml suboru podu
spec:
	tolerations:
	- key: "app"
	  operator: "Egual"
	  value: "blue"
	  effect: "NoSchedule"

====================Node selector====================
#mozeme nim nastavit obmedzenie pre pody, resp minimalne poziadavky na NODY
#node sel ma vela obmedzni - nemozeme pouzit NOT, OR - preto pouzivame  novsie Node Affinity
#najprv musiem olablovat nody, podla ich zdrojov
kubectl label nodes <node-name> <label-key>=<label-value>
kubectl label nodes node-1 size=Large
#zapisueme to pod spec:
spec:
	nodeSelector: 
		size: Large #label v Node

====================Node affinty====================
Ucel je, ze urcity pod bude umiestneny na urcitom node. Negarantuje nam ale, ze tam nemozu umiestnene ine pody, ktore su bez lablov - na to nam sluzi Taints and tolerations.  
Iformaciu o NODE AFFINITY, mozeme zapisat len do yaml suboru, nieje mozne to zapisat pocas create deploy commandu, tz. najprv cez --dry-run vytvorit yaml subor, ten nasledne upravit. 

///////prikazy
kubectl label nodes node-1 size=Large,neco=value #na node pridam labels
kubectl get nodes --show-label #ukaz labely na nodoch - vsetky naraz
kubectl edit deploy existujucideploy #mozeme priamo do beziaceho deployu zapisat Node affinty 

///////Node Affinity types - 
	#vyzaduje aby pri vzniku podu existoval NODE, na ktory bude pod umiestneny
	requiredDuringSchedulingIgnoredDuringExecution - 
	#nevyzaduje aby pri vzniku podu existoval NODE s lablami, ak sa NODE nenajde, tak ho umiestni na iny
	preferredDuringSchedulingIgnoredDuringExecution
	#planovany - vyzaduje aby existoval NODE po
	requiredDuringSchedulingRecquiredDuringExecution
	
///////Zapis Node affinty pod POD specifycation
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: size #size, 
            operator: In #znamena ze pod bude umiesteny v NODE, ktory mu to dovoluje podla lablu, v tomto pripade mame 3 druhy nodov, kde to moze byt umiestnen
			#dalej moze byt NotIn, Exists - ak je exists tak nemusi byt pole values
            values:
            - Large  
			- necoMagicke

====================Resources Requires====================

///////zapis Resources do spec.containers v Specifikacii podu 
spec:
	containers:
	- name: nginx_pod
	  image: nginx
	  ports:
		- containerPort: 8080
	  resources:
		request: #minimalna poziadavka 
			memory: "4Gi"
			cpu: 2
		limits: #urcis limit kolko maximalne zdrojov to moze vziat
			memory: "Gi"
			cpu: 3

#najlepsia alternativa je definovat request ale ziadny limit pre CPU
  
///////THROTTLING - CPU
Ak sa procesor snazi vziat dalsie zdroje, ale LIMITom sa to obmedzi -> procesor si nevezme dalsi zdroj -> PROCESOR THROTLUJE

///////MEMORY
Ak je nastaveny limit na pamat a pamet sa prekroci, tak proces sa ukonci a v logu bude OOM - out of memory. Jediny sposob, ako uvolnit pamat je zabit proces.

#najlepsia alternativa je definovat request ale ziadny limit pre CPU
///////LIMIT RANGE
Je mozne ho aplikovat na urovni Namespace - podobne sa pouziva pre CPU a pre MEMORY
Ak zmenime YAML subor, tak neovplyvni to exisujuce pody, ale len novo vytvorene, alebo aktualizovane

#priklad
apiVersion: v1
kind: LimitRange
metadata:
	name: neco
spec:
	limits:
	- default:
		cpu: 500m
	  defaultRequest:
		cpu: 500m
	  max:
		cpu: "1"
	  min:
		cpu: 100m
	  type: Container

///////	  
Remember, you CANNOT edit specifications of an existing POD other than the below.
spec.containers[*].image
spec.initContainers[*].image
spec.activeDeadlineSeconds
spec.tolerations

For example you cannot edit the environment variables, service accounts, resource limits (all of which we will discuss later) of a running pod. But if you really want to, you have 2 options:

1. Run the kubectl edit pod <pod name> command.  This will open the pod specification in an editor (vi editor). Then edit the required properties. When you try to save it, you will be denied. This is because you are attempting to edit a field on the pod that is not editable.
A copy of the file with your changes is saved in a temporary location 
You can then delete the existing pod by running the command:

kubectl delete pod webapp

Then create a new pod with your changes using the temporary file

kubectl create -f /tmp/kubectl-edit-ccvrq.yaml

2. The second option is to extract the pod definition in YAML format to a file using the command

kubectl get pod webapp -o yaml > my-new-pod.yaml

Then make the changes to the exported file using an editor (vi editor). Save the changes

vi my-new-pod.yaml

Then delete the existing pod

kubectl delete pod webapp

Then create a new pod with the edited file

kubectl create -f my-new-pod.yaml

Edit Deployments
With Deployments you can easily edit any field/property of the POD template. Since the pod template is a child of the deployment specification,  with every change the deployment will automatically delete and create a new pod with the new changes. So if you are asked to edit a property of a POD part of a deployment you may do that simply by running the command

kubectl edit deployment my-deployment

====================Deamon sets====================
Zabezpecuje, ze 1 kopia podu je vzdy na kazdom novom vzniknutom NODE

====================sTATIC Podo====================
Static Pods sú spravované priamo démonom kubelet na konkrétnom uzle bez toho, aby ich sledoval server API

Static pody sa ukladaju ako read only subory do kube-api, takze je mozne ich vidiet medzi beznymi kubectl get pods - maju suffix node na ktorom boli vytovrene, ale nieje mozne ich menit vramci api

Ak mame len samostatnny NODE s kubelet, tak mozeme yaml subory ulozit do /etc/kubernetes/manifests/  a odtial nam bude kubelet tieto subory citat. Subory musia vzdy ostat v tomto priecinku, inac sa so zmazanim suboru odstrani aj pod

Run the command ps -aux | grep kubelet and identify the -- config fil
V --config file najdem staticPodPath. Do tejto cesty mozem nasledne ukladat yaml manifests

Cestu, kde chcem aby kubelet hladal static pod  je:
pod-manifest-path=

Pripadne do kubelet.service zapisem:
--config=kubeconfig.yaml

do kubeconfig.yaml zapisem cestu pre staticPod
staticPodPath: /etc/kubernetes/manifests/

====================Custom Schedulers====================
Kazdy novovytovreny scjeduler musi mat ine meno 
Defaultny scheduler je ulozeny v scheduler-config.yaml, tento scheduler mozeme menit poda potreby
1 scheduler na 1 node
V pripade, ze chceme pouzivat svoj vlatny scheduler, tak si vyvortime novy subor:

/////// scheduler config YAML 

apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles: #pre kazdy scheduler mozeme mat viacero profilov, ktore si mozemem nakonfigurovat rozne , pridat ine pluginy
- schedulerName: hovno-schduler
  plugins:
    score:
	  disabled:
	  - name: TaintToleration
	  enabled:
	  - name: MyCustomPlugin1
	  - name: MyCustomPlugin2
- schedulerName: hovno2
  plugins:
    preScore:
	  disabled:
	  - name: "*"
	score:
	  disabled:
	  - name: "*"
leaderElection:
	leaderElect: TRUE
	resourceNamespace: kube-system
	resourceName:neconecoNeco

Ak chceme spustit scheduler tak ho musime spustit ako POD. V tomto pode musime definvovat, akym config filom sa ma tento scheduler riadit

///////POD scheduler 
apiVersion: v1
kind: Pod
metadata:
  name: my-custom-scheduler
  namespace: dev #vytvori pod v dev NS
spec:
	schedulerName: my-scheduler #urci akym schedulerom bude pod ovladany
	priorityClassName: #priorita schedulera
	
	containers:
	- name: k8s.gcr.io/kube-schduler-amd64:v1.11.3
	  image: kube-schduler
	- kube-scheduler
	- --address=127.0.0.1
	- --kubeconfig=/etc/kubernetes/schduler.conf
	- --config=/etc/kubernetes/my-schduler-config.yaml

///////Profiles / plugins
Scheduling Queue - PrioritySort
Filtering - NodeResourcesFit, NodeName, NodeUnschedulable,
Scoring - NodeResourcesFit, ImageLocality, 
Binding - DefaultBinder



///////Prikazy
kubectl get pods -n kube-system # schedulers hladame vzdy v kube-system
kubectl get event -o wide #zobrazi vsekty eventy v momentalnom NS
kubectl logs my-scheduler -n kube-system #zobrazi logy schedulera

///////Referencie
https://stackoverflow.com/questions/28857993/how-does-kubernetes-scheduler-work
https://kubernetes.io/blog/2017/03/advanced-scheduling-in-kubernetes/

====================Monitoring====================
Metric Server
minikube addons enable metrics-server #ak mam minikube tak pouzit tuto metodu
git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git #pre inu metodu pouzit toto

kubectl top node #zobrazi metriky nodov
kubectl top pod	

====================LOGS====================
kubectl logs -f pod-name 
#V pripade, ze na nasom pode sa nachadza viacero kontajnerov, musime zadat aj nazov containeru
kubectl logs -f pod-name containerName

====================Rolling Updates/rollbacks====================
Deployment strategy
	Recreate - shodi vsetky pody naraz
	Rolling update - default deployment strategy, najprv shodi jeden pod, nasledne vytovri novy - vypina a zapina postupne. 

///////Prikazy
#ak zmenime yaml deploy file tak nasledne pouzijeme 
#vytvorime novu reviziu deployu, tym padom mozeme vratit predoslu verziu cez rollback
kubectl apply -f deploy.yaml
#aktualizovat deployment mozeme aj priamym prikazom, nie len upravov yaml suboru 
kubectl set image deployment/myapp-deploy nginx_container=nginx:1.21.1	

====================vyvorenie PODu z nami vytvoreneho suboru====================
C:\Users\sk8er\Documents\David\02 Linux\Docker.bash
///////POD s argumentom 

apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-pod
  labels:
    app: ubuntu
	tier: server
spec:
	containers:
	- name: ubuntu-sleeper
	  image: ubuntu-sleeper

/////// Command zapis s argumentom

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


====================ENV variable====================
/////// KEY VALUE format
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-pod
  labels:
    app: ubuntu
	tier: server
spec:
	containers:
	- name: ubuntu-sleeper
	  image: ubuntu-sleeper
	  ports:
		- containerPort: 8080
	  env: #tu si urcime ENV value
		- name: APP_COLOR
		  value: poink

///////Config Map
	  env: #tu si urcime ENV value
		- name: APP_COLOR
		  valueFrom: 
			configMapKeyRef: 
			
///////Secrets
	  env: #tu si urcime ENV value
		- name: APP_COLOR
		  valueFrom:
			secretKeyRef:
			
			
====================Config Map====================
https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

///////KEY Value format pre yaml
	APP_COLOR: blue
	APP_MOD: prod
	
///////YAML subor
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  labels:
    app: ubuntu
	tier: server
data:
	APP_COLOR: blue
	APP_MOD: prod

///////Prikazy IMPERATIVE
kubectl create configmap <config_Name> --from-literal=<key>=<value> -from-literal=<key>=<value> #from-literal sa pouziva na specifikaciu key=value priamo v command line
#ak chceme viac key values tak musime zadat viac --from-literal
kubectl create configmap <config_Name> --from-file=<path/to/config-files> #vytovri config file so suboru

///////Prikazy DECLARATIVE
kubectl create -f config-map.yaml

///////Insert ConfigMap to POD
#pod spec.containers.envFrom zapisem
spec:
	containers:
	- name: ubuntu-sleeper
	  image: ubuntu-sleeper
	  ports:
		- containerPort: 8080
	  envFrom:
		- configMapRef:
			name: app-config #vlozime nazov, ktory sme urcili v metadata.name v specifikacii ConfigMap.yaml
			
spec:
	containers:
	- name: ubuntu-sleeper
	  image: ubuntu-sleeper
	  ports:
		- containerPort: 8080
	  env:
		- name: APP_COLOR
		  valueFrom:
			configMapKeyRef:
				name: webapp-config-map
			#pre viac moznosti mrkni https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/


====================Secrets====================
Pouzivaju sa ako configmapy ale maju kodovanie 	nie sifrovanie

///////Prikazy IMPERATIVE
kubectl create secret generic <config_Name> --from-literal=<key>=<value> -from-literal=<key>=<value> #vytvori secret z --from-literal key value par

kubectl create secret generic <config_Name> --from-file=<path/to/config-files> #vytovri secret file so suboru

///////Prikazy DECLARATIVE
kubectl create -f secret.yaml #na vytvorenie potrebujeme YAML subor

///////YAML subor
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
data:
	DB_HOST: mysql
	DB_USER: root
	DB_PASSWORD: paswrd
	#secret data maju byt ulozene v zakodovanom formate

///////Enkrypcia nejakeho textu
echo -n "mysql" | base64 #zakodujem text 
echo -n "kodovany text" | base64 --decode #dekodujem zadany text, ak bol pred tym kodovany base64

///////Prikazy
#standardne ako u ostatnych
kubectl describe secrets #zobrazi obsah secret suboru, ale neukaze hodnoty, ktore su ulozene v DATA
#ked chcem vidiet zakodovane data v secret pouzijem 
kubectl get secret <nazov> -o yaml

///////Insert Secret to POD
#pod spec.containers.envFrom zapisem
spec:
	containers:
	- name: ubuntu-sleeper
	  image: ubuntu-sleeper
	  ports:
		- containerPort: 8080
	  envFrom:
		- secretRef:
			name: app-config #vlozime nazov, ktory sme urcili v metadata.name v specifikacii ConfigMap.yaml
---------------------
		#Single ENV
	  env:
		- name: DB_Password
		  valueFrom: 
			secretKeyRef
				name: app-secret
				key: DB_Password
---------------------
		#VOLUMES
		volumes:
		- name: app-secret-volume
		  secret:
			secretName: app-secret

====================initContainer====================
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'git clone <some-repository-that-will-be-used-by-application> ; done;']
	
	
====================CLUSTER MAINTENENCE====================
Ak aktualizujeme, tak vzdy len o jednu verziu vyssie, nikdy nepreskakujeme 2 verzie.
Najprv je potrebne aktualizovat MASTER node. V pripade, ze aktualizuejem mastra, tak vseteky funkcie na worker nodoch budu bezat, ale nebude fungovat manazment.
Ak sa potrebujeme pripojit na iny node tak pouzijeme 
ssh node01
 
0. Aktualizujeme mastra <control-plane-node>


1. potrebne zmenit cestu v apt - na verziu na ktoru chceme urobit upgrade
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#stiahneme potrebne kluce 
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update

2. potrebne upgradovat kubeadm
#podla madison si najdmeme presnu verziu
sudo apt-cache madison kubeadm 

sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.29.0-1.1' && \
sudo apt-mark hold kubeadm

3. mozeme zacat upgradovat komponenty vramci nodu 
sudo apt-mark unhold kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubelet='1.29.0-1.1' kubectl='1.29.0-1.1'
sudo apt-mark hold kubelet kubectl


4. znovu nastavit schedulable 
kubectl uncordon <node>


///////BACKUP
#mame 2 sposoby ukladania zalohy API a etcd pristup
---API - tato metoda sa pouziva ak neni pristup na ETCD cluster 
Zalohy configu robit na GitHubu 

#Zalohy urobit z kube-apiserver, ktory ma v sebe ulozene vsetky configuracie vsetkuch objektov
kubectl get all --all-namespace -o yaml > all-deploy-conf.yaml
#pouziva sa aj SW Valero, ten urobi zalohy zo vsetkych konfigov

---ETCD - 
#etcd je konzistentné a vysoko dostupné úložisko hodnôt kľúčov, ktoré sa používa ako záložné úložisko systému Kubernetes pre všetky údaje klastra.
#data z etcd.service sa ukladaju defaultne do 
	/var/lib/etcd
#zaloha/snapshot  etcd - musime tiez specifikovat certifikacne subory 
etcdctl snapshot save /full-path/snapshot.db --endpoints=https://127.0.0.1:8080 --cacert=/etc/etcd/ca.cert -cert=/etc/etcd/etcd-server.crt --key=/etc/etcd/etcd-server.key

#novo ulozenu zalohu
#ak chceme obonovit etcd zo zalohy
service kube-apiserver stop

------Obnova{restore}
#na obnovanie dat zo snapshotu, musime nakonfigutrovat novu zlozku v etcd.service
etcdctl snapshot restore /path-to/snapshot.db --data-dir /var/lib/etcd-from-backup

#restartujeme deamona
systemctl deamon-reload
service kube-apiserver start

//////working with ETCDCTL
etcdctl is a command line client for etcd.

To make use of etcdctl for tasks such as back up and restore, make sure that you set the ETCDCTL_API to 3.
You can do this by exporting the variable ETCDCTL_API prior to using the etcdctl client. This can be done as follows:

export ETCDCTL_API=3

Since our ETCD database is TLS-Enabled, the following options are mandatory:

--cacert                                                verify certificates of TLS-enabled secure servers using this CA bundle

--cert                                                    identify secure client using this TLS certificate file

--endpoints=[127.0.0.1:2379]          This is the default as ETCD is running on master node and exposed on localhost 2379.

--key                                                      identify secure client using this TLS key file

Similarly use the help option for snapshot restore to see all available options for restoring the backup.

etcdctl snapshot restore -h

==============Postup z kodekloud na obnovu ETCD
First Restore the snapshot:==========

#otazky a odpovede ohladom Restore
https://github.com/kodekloudhub/community-faq/blob/main/docs/etcd-faq.md
ETCDCTL_API=3 etcdctl  --data-dir /var/lib/etcd-from-backup snapshot restore /opt/snapshot-pre-boot.db

Note: In this case, we are restoring the snapshot to a different directory but in the same server where we took the backup (the controlplane node) As a result, the only required option for the restore command is the --data-dir.


Next, update the /etc/kubernetes/manifests/etcd.yaml:

We have now restored the etcd snapshot to a new path on the controlplane - /var/lib/etcd-from-backup, so, the only change to be made in the YAML file, is to change the hostPath for the volume called etcd-data from old directory (/var/lib/etcd) to the new directory (/var/lib/etcd-from-backup).

  volumes:
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
    name: etcd-data
With this change, /var/lib/etcd on the container points to /var/lib/etcd-from-backup on the controlplane (which is what we want).

When this file is updated, the ETCD pod is automatically re-created as this is a static pod placed under the /etc/kubernetes/manifests directory.



Note 1: As the ETCD pod has changed it will automatically restart, and also kube-controller-manager and kube-scheduler. Wait 1-2 to mins for this pods to restart. You can run the command: watch "crictl ps | grep etcd" to see when the ETCD pod is restarted.

Note 2: If the etcd pod is not getting Ready 1/1, then restart it by kubectl delete pod -n kube-system etcd-controlplane and wait 1 minute.

Note 3: This is the simplest way to make sure that ETCD uses the restored data after the ETCD pod is recreated. You dont have to change anything else.

If you do change --data-dir to /var/lib/etcd-from-backup in the ETCD YAML file, make sure that the volumeMounts for etcd-data is updated as well, with the mountPath pointing to /var/lib/etcd-from-backup (THIS COMPLETE STEP IS OPTIONAL AND NEED NOT BE DONE FOR COMPLETING THE RESTORE)

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

<<<<<<< HEAD
-----------TLS/SSL-----------
=======
////TLS/SSL - Certifikaty 
>>>>>>> refs/remotes/origin/master_notes
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

<<<<<<< HEAD
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

========KUBE-APISERVER====:
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


======Kubeconfig====
=======
====================Autorization====================
-NODE
-ABAC
-RBAC - Role Based Access Control
-Webhook

-----RBAC

Vytvoríme RBAC yaml file kde specifikujeme Rolu
apiVersion: rbac.authorization.k8s.io/v1
kind: Role

Po vytvoreni ROLE musime vytvorit Role-binding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

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

====================Private repository====================
Na to aby sme vytvorili 

///Prikazy
#prihlasenie sa do private-registry
docker login private-registry.io
#spustenie msc z private repository
docker run private-registry.io/apps/internall-app
			       |             |      |
				registry     library  image


