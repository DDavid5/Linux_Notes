====================Manifest Files YAML create ====================
https://www.bluematador.com/learn/kubectl-cheatsheet
Another option for modifying objects is through Manifest Files. We highly recommend using this method. It is done by using yaml files with all the necessary options for objects configured. We have our yaml files stored in a git repository, so we can track changes and streamline changes.

kubectl apply -f manifest_file.yaml #Apply a configuration to an object by filename or stdin. Overrides the exi

====================Creating objects====================
A Kubernetes Pod is a group of one or more Containers, tied together for the purposes of administration and networking. The Pod in this tutorial has only one Container. A Kubernetes Deployment checks on the health of your Pod and restarts the Pod  Container if it terminates. Deployments are the recommended way to manage the creation and scaling of Pods.
///////vytvorenie noveho podu
kubectl run nginx --image=nginx --expose=true #spusti pod s nginx kontajnerom a vytovri servicu s rovnakym menom s default portom 80
kubectl run redis --image=redis --dry-run=client -o yaml > redis.yaml #vygeneruje yaml subor, ktory -o zapise do yaml suboru, pod sa nevytovri --dry-run, a tento ulozi > do yaml suboru
kubectl create deployment nginx --image=nginx #Create a sample deployment 
kubectl expose deployment hello-minikube --type=NodePort --port=8080
kubectl apply -f ./my-manifest.yaml  #vytvor z yaml suboru
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml #Another way to do this is to save the YAML definition to a file and modify

/////Create services
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

====================Replica Set====================
#novsia technologia, nahradzuje replicaControler, 
#vyzaduje k tomu este selector 
kubectl create -f replicaset-def.yaml #spustime repliku zo suboru
kubectl get replicaset #ukaz kolko replik je pripravenych
kubectl delete replicaset myapp-replicaset # zmaze vsetky pody, ktore spadaju do tejto repliky
kubectl edit replicaset myapp-replicaset #prikazom mozem upravit (docasny) subor myapp-replicaset

kubectl apply myapp-replicaset.yaml #po edit musime spustit apply

kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml #we can specify the --replicas option to create a deployment with 4 replicas.

----scaling
#replicaset vie na zaklade matchLabel rozpoznat rovnake pody a na zaklade nich, vie ci ma vytvorit nove


#ak zmenime pocet replik v replicasete, je nutne replica set "nahrat", mame viac moznosti:
kubectl replace --force -f replicaset-def.yaml #najprv prepiseme subor replicaset-def.yaml a potom pomocou prikazu replace nahrajeme repliku znova --force nam zmaze ten povodny
kubectl scale --replicas=6 -f replicaset-def.yaml #nahradime povodny pocet replik a prepiseme to v .yaml subore
kubectl scale --replicas=6 replicaset myapp-replicaset #navysime repliky, ale pocet v YAML sa nezmeni

====================Deployment====================
apiVersion: apps/v1

kubectl create deployment --image=nginx nginx #vytvori jednoduchy deploy bez yaml
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml #Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file.

kubectl create -f deploy.yaml

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

-----delete a Service
By default, the Pod is only accessible by its internal IP address within the Kubernetes cluster. To make the hello-node Container accessible from outside the Kubernetes virtual network, you have to expose the Pod as a Kubernetes Service.

kubectl delete -f ./pod.json # Delete a pod using the type and name specified in pod.json
kubectl delete <object> unwanted --now # Delete a pod with no grace period
kubectl delete pod,service baz foo # Delete pods and services with same names "baz" and "foo"
kubectl delete pods,services -l name=nazovLabelu # Delete pods and services with label name=myLabel

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

-----resurce quota
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

-----Resources
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
	
======Utility Kubectx
#With this tool, you don nott have to make use of lengthy “kubectl config” commands to switch between contexts. This tool is particularly useful to switch context between clusters in a multi-cluster environment.

Installation:

    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
_________________________
///Syntax:
To list all contexts:
    kubectx

To switch to a new context:
    kubectx <context_name>

To switch back to previous context:
    kubectx -

To see current context:
    kubectx -c

======Utility Kubens
#This tool allows users to switch between namespaces quickly with a simple command
///Syntax:

To switch to a new namespace:

    kubens <new_namespace>

To switch back to previous namespace:
    kubens -

====================SCHEDULER/Binding====================
#v YAML subore mozeme urcit na akom node sa ma pod vytvorit tym ze pridame nodeName pod
----manualne priradenie podu na node
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

-----prikazy
#zistenie ci bezi scheduler - scheduler je tiez pod ale v kube-system namespace
kubectl get pod -n kube-system

-----BIND OBJECT
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
-----POST REQ
curl --header "Content-Type:application/json" --request POST --data '{"apiVersion":"v1","kind"": "Binding"...}' 

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
