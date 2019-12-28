#!/bin/bash

DONE="false"
NS="$1"
COUNT="$2"

echo "Waiting for all pods in namespace '$NS' to be ready"
sleep 5

PROGRESS="."

while [ $DONE != "true" ]; do
  PODS=`kubectl get po --namespace=$NS | wc -l`
  RUNNING=`kubectl get po --namespace=$NS | grep 'Running' | wc -l`
  COMPLETED=`kubectl get po --namespace=$NS | grep 'Completed' | wc -l`
  NOTREADY=`kubectl get po --namespace=$NS | grep '0//*' | wc -l`
  PODS=$((PODS-1))
  OKAY=$((RUNNING+COMPLETED))
  NOTREADY=$((NOTREADY-COMPLETED))

  if [ "$PODS" == "$OKAY" ] && [ "$NOTREADY" == "0" ]; then
    echo ""
    echo "All pods are running"
    DONE="true"
  else
    kubectl get po --namespace=$NS
    echo ""
    printf "\r${PODS} pods ($RUNNING are running, $NOTREADY are not yet ready) $PROGRESS               "
    printf "\r${PODS} pods ($RUNNING are running, $NOTREADY are not yet ready) $PROGRESS "
    PROGRESS="$PROGRESS."

    if [ ${#PROGRESS} -eq 10 ]; then
      PROGRESS="."
    fi
  fi

  echo ""

  sleep 10
done

echo "Finished waiting for all pods in namespace '$NS'"
