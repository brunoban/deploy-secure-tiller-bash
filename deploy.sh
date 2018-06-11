#!/usr/bin/env sh

RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[33;5m'
set -e
die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "${RED}Error${NC}: 1 argument required, $# provided"
echo "Checking cluster..."
ref=$(command kubectl config current-context)
if [[ ${ref} =~ ${1} ]]; then
    echo "All good. It seems you are in the correct cluster."
else
    echo "${YELLOW}WARNING${NC}: The cluster you want to install Tiller on doesn't match the one you are currently connected to."
    exit 1
fi

# Generate the Keys for the Tiller installation
./generate_keys.sh ${1}

echo 'Checking namespace'
refns=$(command kubectl get ns)
if [[ ${refns} =~ 'tiller-system' ]]; then
    echo "Tiller namespace found."
else
    ./deploy_rbac.sh ${1}
fi
# Install Tiller securely.
echo "Installing Tiller..."
if [ $# -eq 0 ]; then
    helm init \
    --tiller-tls \
    --tiller-tls-cert tiller-keys/tiller.cert.pem  \
    --tiller-tls-key tiller-keys/tiller.key.pem  \
    --tiller-tls-verify  \
    --tls-ca-cert tiller-keys/ca.cert.pem  \
    --service-account tiller-user  \
    --tiller-namespace tiller-system
else
    helm init \
    --tiller-tls \
    --tiller-tls-cert tiller-keys-${1}/tiller.cert.pem  \
    --tiller-tls-key tiller-keys-${1}/tiller.key.pem  \
    --tiller-tls-verify  \
    --tls-ca-cert tiller-keys-${1}/ca.cert.pem  \
    --service-account tiller-user  \
    --tiller-namespace tiller-system
fi
echo "Done."
echo "Remember that now you need to use the keys to access Tiller."# # Then to use Tiller securely
echo "-----------"
echo "${YELLOW}Example${NC} (List deployments on <environment> cluster):"
echo "helm ls \
--tls \
--tls-ca-cert tiller-keys-${1}/ca.cert.pem \
--tls-cert tiller-keys-${1}/helm.cert.pem \
--tls-key tiller-keys-${1}/helm.key.pem \
--tiller-namespace tiller-system"
echo "-----------"
echo "${YELLOW}Example${NC} (Remove Tiller):"
echo "helm reset \
--tls \
--tls-ca-cert tiller-keys-${1}/ca.cert.pem \
--tls-cert tiller-keys-${1}/helm.cert.pem \
--tls-key tiller-keys-${1}/helm.key.pem \
--tiller-namespace tiller-system"
echo "${RED}Note${NC} If you just want to use a particular set of keys, there is a way to shorten the command:"
echo "cp tiller-keys-${1}/ca.cert.pem $(helm home)/ca.pem && \
 cp tiller-keys-${1}/helm.cert.pem $(helm home)/cert.pem && \
 cp tiller-keys-${1}/helm.key.pem $(helm home)/key.pem"
