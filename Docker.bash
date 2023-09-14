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


