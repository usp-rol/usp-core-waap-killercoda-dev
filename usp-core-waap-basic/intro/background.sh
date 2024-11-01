#!/bin/bash
#
# intro background script log available at /var/log/killercoda/background0_std(err|out).log

# variables
WAIT_SEC=5
JUICESHOP_SETUP_FINISH="/tmp/.juiceshop-finished"
PORT_FORWARD_PID="/tmp/.juiceshop-port-forward-pid"
RC=99

# Part 1: setup juiceshop web app
echo "$(date) : applying juiceshop web app..."
kubectl apply -f ~/.scenario_staging/juiceshop.yaml
echo "$(date) : waiting for juiceshop pod to be ready..."
kubectl wait pods juiceshop -n juiceshop --for='condition=Ready' --timeout=300s
echo "$(date) : wait ${WAIT_SEC}s..."
sleep $WAIT_SEC
echo "$(date) : setting up juiceshop port forwarding..."
while [ $RC -gt 0 ]; do
  pkill -F $PORT_FORWARD_PID || true
  echo "$(date) : ...setting up port-forwarding and testing access..."
  nohup kubectl port-forward -n juiceshop svc/juiceshop 80:8000 --address 0.0.0.0 >/dev/null &
  echo $! > $PORT_FORWARD_PID
  sleep 3
  curl -svo /dev/null http://localhost:80
  RC=$?
done
touch $JUICESHOP_SETUP_FINISH && echo "$(date) : wrote file $JUICESHOP_SETUP_FINISH to indicate juicesetup setup completion to foreground process"
echo "$(date) : juiceshop setup finished"
# Part 2: setup core waap operator
export CORE_WAAP_VERSION=1.1.8
export CORE_WAAP_OP_VERSION=1.0.1
export CORE_WAAP_HELM_VERSION=1.0.2
export CONTAINER_REGISTRY=devuspregistry.azurecr.io
sleep $WAIT_SEC
echo "$(date) : login to helm registry..."
echo "RVkvOFNDMzdWWlo5VWsvSlZFcjRZK2pOSVAraGZiZ29pMmtaSE9DS3k1K0FDUkIrV015Yg==" | base64 -d | helm registry login ${CONTAINER_REGISTRY} --username killercoda --password-stdin
echo "$(date) : change to scenario_staging dir..."
cd ~/.scenario_staging/
echo "$(date) : prepare core waap operator setup..."
kubectl apply -f ./imagepullsecret.yaml
echo "$(date) : patch default serviceaccount in juiceshop namespace..."
kubectl patch serviceaccount default -n juiceshop -p '{"imagePullSecrets": [{"name": "devuspacr"}]}'
echo "$(date) : apply defined variables in helm-values template..."
envsubst < ./operator-helm-template.yaml > ./operator-helm-values.yaml
echo "$(date) : install operator via helm chart..."
helm install \
  usp-core-waap-operator \
  oci://${CONTAINER_REGISTRY}/helm/usp/core/waap/usp-core-waap-operator \
  --version ${CORE_WAAP_HELM_VERSION} \
  --values ./operator-helm-values.yaml
echo "$(date) : copy corewaap custom resouce to user home..."
cp ./juiceshop-core-waap.yaml ~
echo "$(date) : signal foreground script completion..."
touch /tmp/.operator_installed
echo "$(date) : core waap operator setup finished"
