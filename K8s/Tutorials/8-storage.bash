=======Volumes=======
#vramci nodu sa volumes ukladaju do /data/
#volumes vytvarame len na 1 Node Cluser
#ak chceme mat volumes pre multiNode Cluster - pouzijeme nejaky externe riesenie - GluserFS, NFS, Flocker, Fiberchanel, ceph, AWS
#volumes zapiseme vramci pod definiton do
spec
  volumes:
  - name: data-volume
    hostPath:
      path: /data
      type: Directory
#ak chceme tuto volume pouzit pre contajner musime ju do cont zapisat
  containers:
   . . .
   volumeMounts:
   - mountPaht: /opt #v tejto zlozke bude vramci kont ulozene data z datavolume
     name: data-volume
     
 =======Persistent Volumes=======
 #) je časť úložiska v klastri, ktorú poskytol správca alebo ktorá bola dynamicky poskytnutá pomocou tried úložísk
 #urcite nou kolko ma byt vyhradneho priesotru
 #pool z ktoreho si system automaticky vyberie vhodny PV - na zaklade poziadavky podu
 #zadava Administrator a uzivatel nasledne nakonfiguruje PVC - ktora si vyberie vhodny PV
 kind: PersistentVolume
 spec:
	accessModes:
    - ReadWriteOnce
	capacity:
		storage: 1Gi
	hostPath: #nepouzivame v produkci, namiesto toho pouzivame cloud solution napr
	awsElasticBlockStore:
		volumeID: <volume-ID>
		fsType: ext4
   
=======Persistent Volumes Claims=======
 #je požadavek uživatele na úložiště. Je podobný jako Pod. Pody spotřebovávají prostředky uzlu a PVC spotřebovávají prostředky PV
 #sluzi na spojenie s PV
 #kazda PVC moze mat len jedno spojenie (bind) s PV
 kind: PersistentVolumeClaim
 spec:
	accessModes:
		- ReadWriteOnce
	resoruces:
		requests
			storage: 500Mi

#Once you create a PVC use it in a POD definition file by specifying the PVC Claim name under persistentVolumeClaim section in the volumes section like this:

apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
		
=======Storage class=======
#Nahradzuje PV
#vyuziva providerov ako napr GCP, AWS - cloudy
#v pripade potreby zdrojov, automaticky vytvori PV a priradi ich danemu podu. 
#je potrebne upravit PVC s menom danej SC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  storageClassName: slow


