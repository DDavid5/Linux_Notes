====================GIT====================
Branch 	- je nová/oddelená verzia hlavného repozitára.
		- sluzi na to, aby sme pracovali na nejakej casti projektu bez toho aby sme ovplyvnili master branch
		- mozeme mat vytvorene viacero branch, a pracovat na rozdielnych veciach
		- nakoniec mozeme vsetky branch spojit naspat do jednej pomocou

====================Config====================
man git-config
git config --global credential.helper cache #ulozenie hesla, len pre SSH pripojenie
https://git-scm.com/book/id/v2/Git-Tools-Credential-Storage#_credential_caching
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com
====================Branch====================
git branch hello-world-images #vytovrenie novej branch
git branch #zobrazi uz vytvorene branch
git branch -v # zobrazit poslední revizi na každé větvi
Užitečné volby --merged a --no-merged vám z tohoto seznamu umožní vyfiltrovat větve, které jste do aktuální větve buď začlenili, nebo dosud nezačlenili. Chcete-li zjistit, které větve už byly začleněny do větve, na níž se nacházíte, spusťte příkaz git branch --merged:
git branch -a #ukaze vsetky branches aj remote
git branch --set-upstream-to <zdroj>/<JmenoVetveKamPosilat> #aktuální lokální větev automaticky aktualizovat podle vzdálené větve,
Zdroj: https://www.itnetwork.cz/programovani/git/git-prace-se-vzdalenym-repositarem


====================Inicializacia a commit====================
git init #inicializujeme nejaký priečinok ako náš repozitár

Najprv musíme súbory ktoré chceme commitnúť pridať do staging , to znamená, že súbory budu gitom sledované 
git add --all
git add -A  #vsetko pridáme do staging 
git add . 	#do staging pridáme current directory
git 
git status #skontrolujeme status súborov v  repozitári

Ak máme prácu hotovú tak môžeme súbory commitnúť
git commit -m "Nejaký text ktorý popisuje commit"
====================PUSH====================
git push --set-upstream 'remote_name' 'branch_name' #skopíruje na vybrany server 
git push #uploads all local branch commits to the corresponding origingiremote branch.
git push --mirror https://github.com/DDavid5/Public_TUTO #skopíruje na vybrany server

====================PULL/FETCH====================
git fetch [jméno-vzdáleného-repozitáře] #git fetch jen stáhne data do vašeho lokálního repozitáře, neprovede ale automatické sloučení (merge) s vaší prací, ani nezmění nic z toho, na čem právě pracujete
git pull [jméno-vzdáleného-repozitáře] #který automaticky vyzvedne (fetch) a poté začlení (merge) vzdálenou větev do vaší aktuální větve
git fetch -p/--prune[branchname] #pred fetch odstrani vsetky remote referencie, ktore neexistuju na remote

====================Clone====================
git clone --bare https://github.com/DDavid5/Linux_Notes_Tutorial #skopíruje existujúci repozitár, do Bare priečinku a je pripravený repozitár kopírovať

====================remote==================
Manage the set of repositories ("remotes") whose branches you track.
git remote 	#git-remote
git remote -v #Overí novú vzdialenú adresu URL
git remote add origin https://github.com/DDavid5/Linux_Notes_Tutorial.git #pridáme odkaz na vzdialený server, kam chceme zmeny nahrať, v tomto prípade sa jedná o GitHub
git remote add LinuxTask https://github.com/DDavid5/Linux_sysadmin_task #pridame vzdialeny repozitar git remote add <zkrácený název> <url>
git remote rename beanstalk origin #premenujeme 

====================HELP====================
git help --all #vypíše nápovedu pre všetky git príkazyl
git help <příkaz>
git <příkaz> --help
man git-<příkaz>

.gitignore do tohto súboru pridáme súbory, ktoré chceme aby git ignoroval 
====================LOG/Difference====================
git log --oneline --decorate --graph --all #prehladne zobrazenie vet

git diff --color-words #ukaze ake zmeny nastali (porovna predolsi a terajsi stav) a vyfarbi to
git diff branch1..branch2 #porovna 2 vetvy
git log branch1..branch2 #commit differences
git diff master..feature -- <file> #porovna rozdiely suboru medzi 2 vetvami
git diff commithash1..commithash2 #porovna rozdieli medzi 2 commitmi
git diff master my-branch 							
git diff master..my-branch #oba su rovnake

git show :<verze>:<file>
git show :1:soubor.txt > soubor.txt #pro aplikování původní podoby souboru napíšeme
Zdroj: https://www.itnetwork.cz/programovani/git/git-tutorial-vetve

====================Checkout====================
git checkout <other-branch-name> -- path/to/your/folder #presunut subor z other branch do terajsej
Here is the process to follow:
1. Checkout to the branch where you want to copy the file.
git checkout feature/A
2. Once you are on the correct branch, copy the file.
git checkout feature/B -- utils.js
-----------------------------------------------------------------
git checkout hello-world-images #Presun z aktuálnej vetvy do vetvy zadanej na konci príkazu
git checkout -b názov-branche #vytovri a prihlasi sa do novej branch


