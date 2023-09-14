====================GIT====================
Branch 	- je nová/oddelená verzia hlavného repozitára.
		- sluzi na to, aby sme pracovali na nejakej casti projektu bez toho aby sme ovplyvnili master branch
		- mozeme mat vytvorene viacero branch, a pracovat na rozdielnych veciach
		- nakoniec mozeme vsetky branch spojit naspat do jednej
====================Branch====================
git branch hello-world-images #vytovrenie novej branch
git branch #zobrazi uz vytvorene branch
git checkout hello-world-images #Presun z aktuálnej vetvy do vetvy zadanej na konci príkazu

====================Inicializacia a commit====================
git init #inicializujeme nejaký priečinok ako náš repozitár

Najprv musíme súbory ktoré chceme commitnúť pridať do staging , to znamená, že súbory budu gitom sledované 
git add --all
git add -A  #vsetko pridáme do staging 
git add . 	#do staging pridáme current directory

git status #skontrolujeme status súborov v  repozitári

git diff #ukaze ake zmeny nastali (porovna predolsi a terajsi stav)

Ak máme prácu hotovú tak môžeme súbory commitnúť
git commit -m "Nejaký text ktorý popisuje commit"

git help --all #vypíše nápovedu pre všetky git príkazyl

.gitignore do tohto súboru pridáme súbory, ktoré chceme aby git ignoroval 

Manage set of tracked repositories
git remote 	#git-remote -
git remote -v #Overí novú vzdialenú adresu URL
git remote add origin https://github.com/DDavid5/Linux_Notes_Tutorial.git #pridáme odkaz na vzdialený server, kam chceme zmeny nahrať, v tomto prípade sa jedná o GitHub

git clone --bare https://github.com/DDavid5/Linux_Notes_Tutorial #skopíruje existujúci repozitár, do Bare priečinku a je pripravený repozitár kopírovať

git push --mirror https://github.com/DDavid5/Public_TUTO #skopíruje 


