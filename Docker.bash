DOCKER
Inštálácia docker na Raspbian

curl -sSL https://get.docker.com | sh

sudo usermod -aG docker pi #priradím uživateľovi pi práva na docker 

docker run hello-world #stiahne Hello-world a tým zistíme, či docker naozaj beží.
#____________________________-vypíše túto spravu ak je všetko OK

# Hello from Docker!
# This message shows that your installation appears to be working correctly.

# To generate this message, Docker took the following steps:
 # 1. The Docker client contacted the Docker daemon.
 # 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    # (arm32v5)
 # 3. The Docker daemon created a new container from that image which runs the
    # executable that produces the output you are currently reading.
 # 4. The Docker daemon streamed that output to the Docker client, which sent it
    # to your terminal.

# To try something more ambitious, you can run an Ubuntu container with:
 # $ docker run -it ubuntu bash
 

docker version #zisti verziu dockeru

docker pull debian #stiahni kontajner debianu

docker container ls  #zoznam kontajnerov bežiacich 
docker ps  -a #zoznam všetkých kontajnerov

docker exec -it mojdebian bash #pripojenie na kontajner

docker images #zobrazí zozam stiahnutých imidžov

docker rmi IMAGE #vymaže image

docker system prune #vymaže všetky nepoužíté images

https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes

docker stats #štatistky dockera
==========RUN==========
#spusti cont s user 1000 - standardne je spusteny s root opravnenim
docker run --user=1000 ubuntu
#mozeme upravit Dockerfile, v ktorom urcime, ze chceme aby sa cont vzdy spustal s urcitym uzivatelom
USER <user>[:<group>]

or

USER UID[:GID]

==========Security==========
Vsetky moznosti, ktore moze root delat (Linux Capabilieties):
/user/include/linux/capability.h

Docker spusta cont s limitovanym opravnenim - na rozdiel od root v systeme. 
#rootovy v kontajnru pridam opravnenia na urcitu skupinu 
docker run --cap-add MAC_ADMIN ubuntu
#rootovy odoberiem opravnenia v konkretom kont
docker run --cap-drop KILL ubuntu
#prida vsetky opravnenia, ktore ma host root
docker run --privileged ubuntu


#Ak nieje specifikovane inac, procesy v docker sa vzdy spustaju ako root. 
#Ak chceme spustit proces inym uzivatelom, tak pomocou commandu
docker run ---user=meno_usra ubuntu sleep 3600
#alebo v jeho Dockerfile daneho imagu
FROM ubuntu

USER meno_alebo_ID_usra

#ak mame zmeneny Dockerfile tak musime zbuildit
docker build -t my-image

#vramci kontajneru mozeme vidiet beziace procesy
ps aux

#synchornizace času
podman machine ssh sudo date --set $(date +'%Y-%m-%dT%H:%M:%S')


==========Volumes==========
Docker uklada vsetky volumes defaultne do /var/lib/docker/volume
ak chceme spustit kont s nejakou volume:
docker run --mount type=bind,source=/cesta/k/volume,target=/kde/sa/ma/volume/ulozit <nazovKontajneru>
