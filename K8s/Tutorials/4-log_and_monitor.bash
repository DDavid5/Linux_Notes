====================Monitoring====================
Metric Server
minikube addons enable metrics-server #ak mam minikube tak pouzit tuto metodu
git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git #pre inu metodu pouzit toto

kubectl top node #zobrazi metriky nodov
kubectl top pod	

====================LOGS====================
kubectl logs -f pod-name 
#V pripade, ze na nasom pode sa nachadza viacero kontajnerov, musime zadat aj nazov containeru
kubectl logs -f pod-name containerName
