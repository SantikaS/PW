Проект:
Тема: Создание процесса непрерывной поставки для приложения с применением Практик CI/CD и быстрой обратной связью.

1. Установка и развертывание Proxmox VE.
На сайте Proxmox https://www.proxmox.com/en/proxmox-ve/get-started качаем ISO образ, далее устанавливаем его на физический сервер.

2. Подготовка виртуальных машин для кластера Kubernetes:
Загружаем облачный образ Ubuntu 20.04 focal: 
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

Запускаем скрипт create_tpl.sh который создает шаблон ВМ для развертывания.
#! /bin/bash
apt update -y
apt install libguestfs-tools -y
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent
qm create 1000 --name "ubuntu-2004-cloudinit-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0
#qm set 1000 --scsi0 VMs:vm-1000-disk-0,import-from=focal-server-cloudimg-amd64.img
qm importdisk 1000 focal-server-cloudimg-amd64.img VMs
qm set 1000 --scsihw virtio-scsi-pci --scsi0 VMs:1000/vm-1000-disk-0.raw
qm set 1000 --boot c --bootdisk scsi0
qm set 1000 --ide2 VMs:cloudinit
qm set 1000 --serial0 socket --vga serial0
qm set 1000 --agent enabled=1
qm template 1000

Устанавливаем Terraform, переходим в папку terraform

$ cd terraform
$ terraform plan
$ terraform apply

После успешного развертывания должны создаться виртуальные машины:
1 – kube-server
2 – kube-agent

3. Развертывание кластера Kubernetes.

Для этого будем использовать Ansible

Переходим в папку Ansible
$ cd ../ansible

Проверяем что все ВМ доступны
$ ansible -i ansible-hosts.txt all -u ubuntu -m ping

Устанавливаем зависимости
$ ansible-playbook -i ansible-hosts.txt ansible-install-kubernetes-dependencies.yml

Инициализируем кластер
$ ansible-playbook -i ansible-hosts.txt ansible-init-cluster.yml

Подключаемся к серверу и рабочим узлам
$ ansible-playbook -i ansible-hosts.txt ansible-get-join-command.yml
$ ansible-playbook -i ansible-hosts.txt ansible-join-workers.yml

$ kubectl get nodes
NAME             STATUS   ROLES                  AGE     VERSION
kube-agent-01    Ready    <none>                 4d18h   v1.21.7
kube-agent-02    Ready    <none>                 4d18h   v1.21.7
kube-server-01   Ready    control-plane,master   4d18h   v1.21.7

Устанавливаем веб интерфейс 
Переходим в корень проекта
cd ..

Создадим сертификаты
openssl req -new -x509 -days 1461 -nodes -out cert.pem -keyout cert.key -subj "CN=kubernetes.santikas.local/CN=kubernetes“

Создадим namespace, настрйку для секретов и задеплоим
$ kubectl create namespace kubernetes-dashboard
$ kubectl create secret generic kubernetes-dashboard-certs --from-file=cert.key --from-file=cert.pem -n kubernetes-dashboard
$ kubectl create -f recommended.yaml
$kubectl create -f dashboard-admin.yaml

На сервере вводим команду для создания сервисной учетной записи:
$ kubectl create serviceaccount dashboard-admin -n kube-system

Создадим привязку нашего сервисного аккаунта с Kubernetes Dashboard:
$ kubectl create clusterrolebinding dashboard-admin 
--clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin

Получаем токен для подключения
$ kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | 
awk '/dashboard-admin/{print $1}')

Теперь открываем браузер и переходим по ссылке https://<IP-адрес мастера>:30001
Используя полученный токен, вводим его в панели авторизации

4. Установка и развертывание GitLab .

Установим gitlab следующей командой
$ helm upgrade --install gitlab  gitlab/gitlab --set global.hosts.domain=santikas.mcdir.me --set gitlab-runner.runners.privileged=true --set certmanager-issuer.email=santikas@yandex.ru  --version 6.4.5 --set postgresql.image.tag=13.6.0 -n gitlab

Подождем пока поднимутся все поды
Далее для получения пароля вводим:
$ kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

Входим в UI Gitlab
Авторизируемся с логином root и полученным паролем.

Создаем группу
Делаем ее публичной.

Далее идем в настройки группы:
Settings / CI/CD

Добавляем две переменные CI_REGISTRY_USER и CI_REGISTRY_PASSWORD
Логин и пароль от DockerHub соответственно 
Можно создать в DockerHub токен и внести суда его. 

Далее создаем проекты
se_ui
se_crawler
se_deploy

5. Сборка, тестирование и развертывание приложения в GitLab

Для этого в GitLab необходимо добавить агента для связи с Kubernetes
и runner  для запуска приложений.

Добавляем удаленный репозиторий GitLab
$ git remote add origin http://192.168.77.11/santikas/se-ui.git

Коммитим и пушим приложение в наш GitLab
$ git commit -m “init”
$ git push origin master

Тоже самое проделываем с приложением crawler.

После пуша начинается автоматическая сборка приложений.

За тем, подобным образом выкатываем наше приложение в продакшн.

$cd ../se_deploy
$ git commit -m “prod”
$ git push origin master

Ждем некоторое время, наблюдаем, что поды нашего приложения поднялись.

Далее проверяем запущенные сервисы и заходим в браузере в наше приложение.

Приложение выдает метрики, доступ к которым прописываем в prometheus

Визуализацию метрик можно увидеть в Grafana.





