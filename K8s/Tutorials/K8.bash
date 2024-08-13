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

====================Creating objects====================
A Kubernetes Pod is a group of one or more Containers, tied together for the purposes of administration and networking. The Pod in this tutorial has only one Container. A Kubernetes Deployment checks on the health of your Pod and restarts the Pod  Container if it terminates. Deployments are the recommended way to manage the creation and scaling of Pods.
///////vytvorenie noveho podu
kubectl run nginx --image=nginx --expose=true #spusti pod s nginx kontajnerom a vytovri servicu s rovnakym menom s default portom 80
kubectl run redis --image=redis --dry-run=client -o yaml > redis.yaml #vygeneruje yaml subor, ktory -o zapise do yaml suboru, pod sa nevytovri --dry-run, a tento ulozi > do yaml suboru
kubectl create deployment nginx --image=nginx #Create a sample deployment 
kubectl expose deployment hello-minikube --type=NodePort --port=8080
kubectl apply -f ./my-manifest.yaml  #vytvor z yaml suboru
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml #Another way to do this is to save the YAML definition to a file and modify

#Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379,
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml  #this will automatically use the pod's labels as selectorse

Or

kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml #(This will not use the pods labels as selectors, instead it will assume selectors as app=redis. You cannot pass in selectors as an option. So it does not work very well if your pod has a different label set. So generate the file and modify the selectors before creating the service)

#Create a Service named nginx of type NodePort to expose pod nginx's port 80 on port 30080 on the nodes:
kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml #(This will automatically use the pod's labels as selectors, but you cannot specify the node port. You have to generate a definition file and then add the node port in manually before creating the service with the pod.)

kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml #(This will not use the pods labels as selectors)



====================Viewing and finding resources====================
kubectl get pods  #zobraz deployment
kubectl get pods -o wide #zobrazi podrobnejsi popis podov
kubectl describe pod nazovPodu #detail podu
kubectl get po --all-namespaces (-A)  #access your shiny new cluster:
kubectl get services --sort-by=.metadata.name # List Services Sorted by Name


====================delete a Service====================
By default, the Pod is only accessible by its internal IP address within the Kubernetes cluster. To make the hello-node Container accessible from outside the Kubernetes virtual network, you have to expose the Pod as a Kubernetes Service.

kubectl delete -f ./pod.json # Delete a pod using the type and name specified in pod.json
kubectl delete pod unwanted --now # Delete a pod with no grace period
kubectl delete pod,service baz foo # Delete pods and services with same names "baz" and "foo"
kubectl delete pods,services -l name=nazovLabelu # Delete pods and services with label name=myLabel

==================== POD ====================
///////YAML
#poivinne polia v yaml subore
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
	tier: frontend
spec:
	containers:
	- name: nginx
	  image: nginx
	  
///////Prikazy
kubectl run nginx --image=nginx --expose=true #spusti pod s nginx kontajnerom a vytovri servicu s rovnakym menom s default portom 80
kubectl run redis --image=redis --dry-run=client -o yaml > redis.yaml #vygeneruje yaml subor, ktory -o zapise do yaml suboru, pod sa nevytovri --dry-run, a tento ulozi > do yaml suboru	  
kubectl replace --force -f neco.yaml #zmaze a znovu vytvori pod --force aj beziaci/funkcnys
#Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379,
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml  #this will automatically use the pod's labels as selectorse
kubectl get pod --selector app=App1 #vyfiltruje vsetky pody, ktore maju label app=App1
kubectl replace --force -f neco.yaml #nahradime uz existujuci pod novym suborom --force nam ten povodny zmaze


====================Manifest Files YAML create ====================
https://www.bluematador.com/learn/kubectl-cheatsheet
Another option for modifying objects is through Manifest Files. We highly recommend using this method. It is done by using yaml files with all the necessary options for objects configured. We have our yaml files stored in a git repository, so we can track changes and streamline changes.

kubectl apply -f manifest_file.yaml #Apply a configuration to an object by filename or stdin. Overrides the existing configuration.

====================Replica Controller====================
apiVersion: v1
kind: ReplicationControler
metadata:
  name: myapp-rc
  labels: 
    app: myapp
	type: FE
spec:
    - template:
     #sem pridam yaml definiciu noveho podu 
        metadata:
          name: nginx
          labels:
            app: nginx
            tier: frontend
        spec:
            containers:
            - name: nginx
    replicas: 3
    
kubectl create -f replicaController.yml #spustim replica controller
kubectl get replicationcontroler #ukaz rep contrler, kolko replik je pripravenych

====================Replica Set - create====================
#novsia technologia, nahradzuje replicaControler, 
#vyzaduje k tomu este selector 
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: myapp-rc
    labels: 
      app: myapp
      type: FE
spec:
    template:
     #sem pridam yaml definiciu noveho podu 
        metadata:
          name: nginx
          labels:
            app: nginx
            
        spec:
            containers:
            - name: nginx
    replicas: 3
    selector: 
      matchLabels:
        app: nginx #label sa musia zhodovat s tymi v tamplate 
       
        
kubectl create -f replicaset-def.yaml #spustime repliku zo suboru
kubectl get replicaset #ukaz kolko replik je pripravenych
kubectl delete replicaset myapp-replicaset # zmaze vsetky pody, ktore spadaju do tejto repliky
kubectl edit replicaset myapp-replicaset #prikazom mozem upravit (docasny) subor myapp-replicaset

kubectl apply myapp-replicaset.yaml #po edit musime spustit apply

kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml #we can specify the --replicas option to create a deployment with 4 replicas.



====================ReplicaSet - scaling====================
#replicaset vie na zaklade matchLabel rozpoznat rovnake pody a na zaklade nich, vie ci ma vytvorit nove


#ak zmenime pocet replik v replicasete, je nutne replica set "nahrat", mame viac moznosti:
kubectl replace --force -f replicaset-def.yaml #najprv prepiseme subor replicaset-def.yaml a potom pomocou prikazu replace nahrajeme repliku znova --force nam zmaze ten povodny
kubectl scale --replicas=6 -f replicaset-def.yaml #nahradime povodny pocet replik a prepiseme to v .yaml subore
kubectl scale --replicas=6 replicaset myapp-replicaset #navysime repliky, ale pocet v YAML sa nezmeni
                            #TYPE          #NAME
                            
====================Deployment====================
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp-depoloyment
    labels: 
      app: myapp
      type: FE
spec:
    template:
     #sem pridam yaml definiciu noveho podu 
        metadata:
          name: nginx
          labels:
            app: nginx
            
        spec:
            containers:
            - name: nginx
			  image: nginx
			schedulerName:  my-scheduler
    replicas: 3
    selector: 
      matchLabels:
        app: nginx #label sa musia zhodovat s tymi v tamplate 
         
kubectl create deployment --image=nginx nginx #vytvori jednoduchy deploy bez yaml
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml #Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file.


kubectl create -f deploy.yaml

kubectl get deploy

#Pri zmene deploy.yaml súboru, tento súbor znovu spustíme príkazom:
kubectl apply -f deployment.yaml

#Pomocou prikazu môžeme zmeniť/aktualizovať len image v deploy.yaml súbore:
kubectl set image deployment/myapp-deployment nginx-container=nginx:1.9.1

====================Rollout====================
#je mozne pouzit len pri deploymente 
#ak zmenime yaml deploy file tak nasledne pouzijeme 
#vytvorime novu reviziu deployu, tym padom mozeme vratit predoslu verziu cez rollback
kubectl apply -f deploy.yaml

#aktualizovat deployment mozeme aj priamym prikazom, nie len upravov yaml suboru 
kubectl set image deployment/myapp-deploy nginx_container=nginx:1.21.1	

#ukaze status rolloutu:
kubectl rollout status deployment/mydeploy

#ukaze historiu rolloutou:
kubectl rollout history deployment/mydeploy

#vratime upgrade na povodnu verziu:
kubectl rollout undo deployment/mydeploy

kubectl get all #zobrazime vsetky objekty naraz
====================Service====================
NodePort - sluzi na komunikaciu z vonku do Nodu
ClusterIP - virtualna IP - komunikacia medzi ostatnymi servicami
LoadBalancer - cloud provider

Target port: port na cielovom pode - servica tam  bude posielat requesty
port: port service samotnej - okrem toho ma servica vlastnu IP, ktora sa oznacuje ako ClusterIP
NodePort: na tento sa na servicu pripaja z externeho zdroja :30000-32767


apiVersion: v1
kind: Service
metadata: 
    name: myapp-service
    labels: app: front-end
spec:
    type: NodePort
    ports:
       - targetPort: 80
         port: 80
         nodePort: 30008
    selector:
        app: myapp
        type: front-end #lable z pod-definition

kubectl create -f service.yaml

====================Namespaces====================
///// definicia noveho NS v .yaml subore
apiVersion: v1
kind: Namespace
metadata: 
    name: dev
    
///////definicia v akom NS sa ma dany pod vytvorit
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: dev #vytvori pod v dev NS
  labels:
    app: nginx
	tier: frontend
spec:
	containers:
	- name: nginx
	  image: nginx

#pripojenie na sluzby v inom NS
 db-service.dev.svc.cluster.local
    |        |  |        |
service name NS service  domain

#ak chceme nieco vidiet v inom NS tak pouzijeme --namespace=nazovNamespace alebo kratka forma -n=nazovNamespaces
//////prikazy
kubectl create ns dev #vytvori NS napriamo bez YAML
kubectl create -f namespaceName #vytvori NS cez yaml
kubectl config set-context $(kubectl config current-context) -- namespace=dev #zmena z aktualneho NS do noveho ns 
///////resurce quota///////
#sluzi na urcenie ake zdoje sa maju pouzit pre dany NS
apiverision: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: dev
spec:
  hard:
    pods: "10"
    request.cpu: "4"
    request.memory: 5Gi
    limits.cpu: "10"
    limits.memory: 10Gi
	


====================SCHEDULER/Binding====================
#v YAML subore mozeme urcit na akom node sa ma pod vytvorit tym ze pridame nodeName pod
///////manualne priradenie podu na node
#zmenime yaml file - je mozne len v pripade ze nebezi Pod
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
	tier: frontend
spec:
	containers:
	- name: nginx
	  image: nginx
	nodeName: node01

///////prikazy
#zistenie ci bezi scheduler - scheduler je tiez pod ale v kube-system namespace
kubectl get pod -n kube-system

///////BIND OBJECT
#v pripade, ze POD bezi musime vyvorit BIND objekty
apiVersion: v1
kind: Binding
metadata:
  name: nginx
target:
  apiVersion: v1
  kind: Node
  name: node02 #tymeto urcime na aky node sa ma pripojit pod

#Poslat POST request na POD aby to spojil s Nodom, pripaden upravit yaml. Vymazat existujuci pod a znovu vytvorit.
///////POST REQ
curl --header "Content-Type:application/json" --request POST --data '{"apiVersion":"v1","kind"": "Binding"...}' 

====================Resources====================
#nieje to povinne nastavenie, ale je odporucane
spec:
	containers:
	- name: nginx_pod
	  image: nginx
	  ports:
		- containerPort: 8080
	  resources:
		request: #minimalna poziadavka - najlepsie vzdy urcit, aby mal kazdy pod nejaky zdroj
			memory: "4Gi"
			cpu: 2
		limits: #urcis limit kolko maximalne zdrojov to moze vziat, 
			memory: "Gi"
			cpu: 3

///////THROTTLING - CPU
Ak sa procesor snazi vziat dalsie zdroje, ale LIMITom sa to obmedzi -> procesor si nevezme dalsi zdroj -> PROCESOR THROTLUJE

///////MEMORY
Ak je nastaveny limit na pamat a pamet sa prekroci, tak proces sa ukonci a v logu bude OOM - out of memory. Jediny sposob, ako uvolnit pamat je zabit proces.

#najlepsia alternativa je definovat request ale ziadny limit pre CPU
///////LIMIT RANGE
Je mozne ho aplikovat na urovni Namespace
====================Deamon sets==================
Zabezpecuje, ze 1 kopia podu je vzdy na kazdom novom vzniknutom NODE

///////priklad
apiVersion: apps/v1
kind: DeamonSet
metadata:
    name: monitoring-deamon
    labels: 
      app: myapp
      type: FE
spec:
    template:
     #sem pridam yaml definiciu noveho podu 
        metadata:
          name: grafana
          labels:
            app: monitoring-agent            
        spec:
            containers:
            - name: monitoring-agent
			  image: monitoring-agent
    selector: 
      matchLabels:
        app: monitoring-agent #label sa musia zhodovat s tymi v tamplate 
====================DRAIN====================
#Presunie pody na iny node, aby sme mohli node restartovat
kubectl drain node-1
#odblokujeme node, aby bolo mozne na neho znovu presuut pody
kubectl uncordon node-1 

====================CLUSTER MAINTENENCE====================
///////struktura komponentov
kube-apiserver #musi byt novsi ako vsekty ostane 
	cotroller-manager ; kube-scheduler #mozu byt 1 verziu menssie
		kubelet ; kube-proxy #mozu byt 2 verzie nizsie od kubeapi-server
		
kubectl #moze byt 1 verziu + alebo - 

///////Prikazy
#Vypise nam aktualne verzie kube komponentov
kubeadm upgrade plan

#Aktualizujem kubeadm na najnovsiu verziu,
#Kubeadm musi byt aktualizovany prvy
apt-get upgrade -y kubeadm
kubeadm upgrade apply <verzia>
apt-get upgrade -y kubelet <verzia>

#postup pri update jednotlivych nodoch
apt-get upgrade -y kubeadm=<verzia>
apt-get upgrade -y kubelet=<verzia>
kubeadm upgrade node config --kubelet-version <version>
systemctl restart kubelet

====================Security====================

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

====ClusterRoles

====Role Bindings

====================Private repository====================

apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
	tier: frontend
spec:
	containers:
	- name: nginx
	  image: private-registry.io/apps/internall-app #nahradime celym menom domeny vid CKA.bash 
#autenfikacia secret suboru
	imagePullSecrets:
	- name: regcred




