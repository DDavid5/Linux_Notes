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
