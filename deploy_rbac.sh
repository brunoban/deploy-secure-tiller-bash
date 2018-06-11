#!/usr/bin/env sh

set -e
echo "Checking permissions..."
cluster_owner=$(kubectl describe clusterrolebinding owner-cluster-admin-binding | grep User | cut -f5 -d ' ')
gcloud_email=$(gcloud info | grep Account | cut -f2 -d ' ' | tr -d [])
if [[ $cluster_owner != $gcloud_email ]]; then
    kubectl create clusterrolebinding owner-cluster-admin-binding --clusterrole cluster-admin --user $gcloud_email
fi
echo "Creating Tiller Permissions/Namespace..."
kubectl create -f "tiller.yaml" || true
echo "Done!"