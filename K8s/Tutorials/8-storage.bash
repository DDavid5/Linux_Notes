=======Volumes=======
#vramci nodu sa volumes ukladaju do /data/
#volumes vytvarame len na 1 Node Cluser
#ak chceme mat volumes pre multiNode Cluster - pouzijeme nejaky externe riesenie - GluserFS, NFS, Flocker, Fiberchanel, ceph, AWS
#volumes zapiseme vramci objektu do
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
 kind: PersistentVolume
 spec:
   accessModes:
    - ReadWriteOnce

=======Persistent Volumes Claims=======
 #je požadavek uživatele na úložiště. Je podobný jako Pod. Pody spotřebovávají prostředky uzlu a PVC spotřebovávají prostředky PV
 #sluzi na spojenie s PV
 persistentVolumeTrvlsimPolicy #urcime co 
