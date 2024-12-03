#---CONFIG Files----
CFG file môže byť ulozeny v roznych zlozkach, od najnizsej priority:

/etc/ansible/ansible.cfg - defaultnty cfg file, je potrebné ho vytvorit
/home/ansilbe/.ansible.cfg - tento cfg je v hierarchii vyssie ako defaultny
home/ansible/mojazlozka/ansible.cfg - ak cfg vo vyssej zlozke ako ansible, tak umiestnenie bude vrámci tejto zlozky
ANSIBLE_CONFIG - najvyssia priorita:
    export ANSIBLE_CONFIG=/home/ansible/this-is-my-config-file.cfg
#  ----------------------------------------------------------------------------------
ansible --version                                                                   |
#zistime verziu ansible + dalsie info, priklad:                                     |
ansible [core 2.17.4]                                                               |
  config file = /home/ansible/.ansible.cfg  #<----------------------------------------
  configured module search path = ['/home/ansible/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.10/dist-packages/ansible
  ansible collection location = /home/ansible/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.10.12 (main, Jul 29 2024, 16:56:48) [GCC 11.4.0] (/usr/bin/python3)
  jinja version = 3.1.4
  libyaml = True

#=ansible.cfg
[defaults]
host_key_checking = False #neoveruje ci zadany host je v zlozke .ssh/known_hosts
serial 2 #Ak chcete naraz spravovať len niekoľko strojov, napríklad počas priebežnej aktualizácie, môžete definovať, koľko hostiteľov má Ansible spravovať naraz, pomocou kľúčového slova serial
serial: 20%
strategy: free

#---Tags---
#spusti len tasky s tagmi
ansible-playbook nazvv-playbooku.yaml --tags"install-epel,install-nginx"
#preskoci tasky
ansible-playbook nazvv-playbooku.yaml --skip-tags"install-epel,install-nginx"
#specialne tagy:
--tags "tagged" #spusti vsetky tasky, ktoré sú otagovane
--tags "untagged"
--tags "all"
#ukazka tagu v playbooku
{
  tags: #je mozne otagoat cely playbook
    - webapp
  tasks:
    - name: Install EPEL
...
      tags:
        - install-epel

    - name: Install Nginx
...
      tags:
        - install-nginx

    - name: Restart nginx
      service:
...
      tags:
        - restart-nginx
}

#---Roles---
ansible-galaxy init nginx
{

}

# ---Hosts file----
{
[control]
ubuntu-c ansible_connection=local

[centos]
centos1 ansible_port=2222 #pripojit sa na hosta s portom 2222, defaut port je 22 (SSH)
centos[2:3]

[centos:vars]
ansible_user=root

[ubuntu]
ubuntu[1:3]

[ubuntu:vars] #vsetky ubunutu "zdedia" tieto premenné
ansible_become=true # ansible_becom = urcitme ze ansible user bude root,
ansible_become_pass=password # ansible_become_pass zadame heslo na to aby sme mohli byt sudo

[all:vars] #ak je port specifikovany vrámci hostu, tak má prednosť pred :vars
ansible_port=123

[linux:children] #urcime potomkov skoupiny linux
centos
ubuntu
}

# ---ansible-doc---
ansible-doc file #zobrazime manual pre jednotlivy modul

# ---Ansible command----
ansible name-of-group --list-hosts #zobraz mi hostov v grupe inac je mozne sa pozriet do zlozky ansible/hosts
ansible name-of-group -m ping -o #-m modul ping, -o/--oneline vystup zobrazi na jeden riadok
ansible linux  -m ping -e "ansible_port=2222" -o #-e prepíseme hodnotu, ktorá je v hosts


 #---Module----

 # === File module
 ansible name-of-group  -m file -a "path=/tmp/test state=file" #-m pouzi modul file, -a argument musí byť vrámci uvodzoviek a je mozne tam pisat parametre
 # https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html#parameter-modification_time

 # ===Copy module
 ansible all -m copy -a "dest=/tmp/y src=/tmp/x"

 #---Playbooks----
ansible-playbook nazov_suboru.yaml
#prdaj do playbooku -e extra premennu
#INI
ansible-playbook variables_playbook.yaml -e extra_vars_key="extra vars value"
#JSON:
ansible-playbook variables_playbook.yaml -e {"extra_vars_key": "extra vars value"}
#YAML
ansible-playbook variables_playbook.yaml -e {extra_vars_key: extra vars value}
#passing variables as a yaml file
ansible-playbook variables_playbook.yaml -e @extra_vars_file.yaml

###obsah playbooku, priklad
{
  ---
  # The minus in YAML this indicates a list item.  The playbook contains a list
  # of plays, with each play being a dictionary
-
  hosts: centos
  user: root
  gather_facts: False #zastavi zbieranie facts o hostoch, zníži čas vykonania

  # Vars: variables that will apply to the play, on all target systems
  vars:
    motd: "Welcome to CentOS Linux - Ansible Rocks\n"

  vars_prompt:
    - name: username
      private: False

  # Tasks: the list of tasks that will be executed within the playbook
  tasks:
    - name: Configure a MOTD (message of the day)
      copy:
        content: "{{ motd }}"
        dest: /etc/motd
      notify: MOTD changed #ak zmena prebehne, tak informuj handler, musi byt rovnaky nazov

    - name: Test vars_prompt
      debug:
        msg: "{{ username }}"

  # Handlers: sú spustene len raz na konci taskov, sluzia na notifikaciu
  handlers:
      - name: MOTD changed
      debug:
        msg: The MOTD was changed

  # Roles: list of roles to be imported into the play
...
### Three dots indicate the end of a YAML document
}

#===Vars
{
  # zapis premennej
  vars:
    inline_dict:
      {inline_dict_key: This is an inline dictionary value}
  #volanie premennej
  #vzdy musi byt vramci ""
  #pouzivat python sytax s []
  {
    tasks:
    - name: Test named inline dictionary dictionary
      debug: #obsah celej premennej/dictionary
      msg: "{{ inline_dict }}"

    - name: Test named inline dictionary dictionary key value with brackets notation
      debug: #zavolanie konkretneho kluca, zobrazi sa nam value
      msg: "{{ inline_dict['inline_dict_key'] }}"
  }
}

#===hostvars
#facts can be access with the hostvars variable.
{
tasks:
    - name: Test hostvars with an ansible fact and collect ansible_port, dot notation
      debug:
        msg: "{{ hostvars[ansible_hostname].ansible_port }}"
}

# === external var, var_file
{
  #premenne mozu byt ulozene aj v inom subore:
  {
    external_example_key: example value

    external_dict:
    dict_key: This is a dictionary value

    external_inline_dict:
    {inline_dict_key: This is an inline dictionary value}

    external_named_list:
    - item1
    - item2
    - item3
    - item4

    external_inline_named_list:
    [ item1, item2, item3, item4 ]
  }

  #ZAPIS EXTERNAL PREMENNEJ V PLAYBOOKU:
  vars_files:
  - external_vars.yaml
}

# === vars_prompt
#caka na interakciu od uzivatela
{
vars_prompt:
    - name: password
      private: True
}

#===group_vars, host_vars

V zlozke group_vars/, host_vars/ mozmee mat ulozene premenne, t
v host_vars musi byt subor, ktory sa vola rovnako ako host v subore hosts
{
#===host_vars
#obsah suboru hosts:
{
[control]
ubuntu-c

[centos]
centos[1:3]

[ubuntu]
ubuntu[1:3]
}

#obash suboru host_vars/centos1:
---
ansible_port: 2222 #ansible_port je definovana premenna
...

#===group_vars
#obsah zlozky group_vars/centos
---
ansible_user: root
nginx_root_location: /usr/share/nginx/html
...

#obsah playbooku, s načítaním group_vars
  tasks:
    - name: Template index.html-base.j2 to index.html on targer
      template:
        dest: "{{ nginx_root_location }}/index.html"
        src: index.html-base.j2
        mode: 0644

}

#---Facts----
{
  #defaultne ulozene v:
  /etc/ansible/facts.d/
  #je tam mozne ulozit aj customfacts vo formate json alebo INI

  # JSON format - ulzime do facts.d
  #!/bin/bash
  echo {\""date\"" : \""$(date)\""}

  #custom fact zavolame v cez premeennu, ktorú si najdeme cez filter, viz sekce setupmodul

  #===set_fact modul
  #Táto akcia umožňuje nastavenie premenných súvisiacich s aktuálnym hostiteľom
  #Tieto premenné budú dostupné pre nasledujúce hry počas behu ansible-playbook prostredníctvom hostiteľa, na ktorom boli nastavené.
  #zápis v playbooku ako key: value alebo key=value
  {
    tasks:
    - name: Set our installation variables for CentOS
    set_fact:
    webserver_application_port: 80
    webserver_application_path: /usr/share/nginx/html
    webserver_application_user: root
    when: ansible_distribution == 'CentOS'
  }

  #===setup modul
  #zobraz fakty len o network
  ansible centos -m setup -a "gather_subset=network"
  #filter, je mozne pouzit wildcard
  ansible centos -m setup -a "filter=ansible_mem*"
}

#---Register----
#ulozime vystup z prikazu do premennej
#premennu mozeme neskor pouzit
{
tasks:
    - name: Exploring register
      command: hostname -s
      register: hostname_output

    - name: Show hostname_output
      debug:
        var: hostname_output
}

#---JINJA2----
#===Filter
splitted: "{{ name.split(' ') | lower }}"
joined: "{{ splitted | join('.') }}"

# subor  musi byt ulozeny vo formate .j2, nasledne v nom je mozne pouzivat premenne

#
# ===IF
{% if ansible_memtotal_mb > 100 %}
Memory is large
{% else %}
Memory is small
{% endif %}


#===FOR
{% for host in groups["all"] %}
{{facts}}
{% endfor %}
