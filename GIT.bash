====================GIT====================
Branch 	- je nová/oddelená verzia hlavného repozitára.
		- sluzi na to, aby sme pracovali na nejakej casti projektu bez toho aby sme ovplyvnili master branch
		- mozeme mat vytvorene viacero branch, a pracovat na rozdielnych veciach
		- nakoniec mozeme vsetky branch spojit naspat do jednej
====================Branch====================
git branch hello-world-images #vytovrenie novej branch
git branch #zobrazi uz vytvorene branch
git checkout hello-world-images #Presun z aktuálnej vetvy do vetvy zadanej na konci príkazu
git branch -v # zobrazit poslední revizi na každé větvi
Užitečné volby --merged a --no-merged vám z tohoto seznamu umožní vyfiltrovat větve, které jste do aktuální větve buď začlenili, nebo dosud nezačlenili. Chcete-li zjistit, které větve už byly začleněny do větve, na níž se nacházíte, spusťte příkaz git branch --merged:

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
====================PUSH====================
git push 'remote_name' 'branch_name' #skopíruje na vybrany server 
git push #uploads all local branch commits to the corresponding remote branch.
git push --mirror https://github.com/DDavid5/Public_TUTO #skopíruje na vybrany server
====================Clone====================
git clone --bare https://github.com/DDavid5/Linux_Notes_Tutorial #skopíruje existujúci repozitár, do Bare priečinku a je pripravený repozitár kopírovať
====================PULL FETCH====================
git fetch [jméno-vzdáleného-repozitáře] #git fetch jen stáhne data do vašeho lokálního repozitáře, neprovede ale automatické sloučení (merge) s vaší prací, ani nezmění nic z toho, na čem právě pracujete
git pull [jméno-vzdáleného-repozitáře] #který automaticky vyzvedne (fetch) a poté začlení (merge) vzdálenou větev do vaší aktuální větve
====================remote==================
Manage the set of repositories ("remotes") whose branches you track.
git remote 	#git-remote
git remote -v #Overí novú vzdialenú adresu URL
git remote add origin https://github.com/DDavid5/Linux_Notes_Tutorial.git #pridáme odkaz na vzdialený server, kam chceme zmeny nahrať, v tomto prípade sa jedná o GitHub
git remote add LinuxTask https://github.com/DDavid5/Linux_sysadmin_task #pridame vzdialeny repozitar git remote add <zkrácený název> <url>

====================HELP====================

git help --all #vypíše nápovedu pre všetky git príkazyl
git help <příkaz>
git <příkaz> --help
man git-<příkaz>

.gitignore do tohto súboru pridáme súbory, ktoré chceme aby git ignoroval 
====================LOG====================
git log --oneline --decorate --graph --all #prehladne zobrazenie vetiev








