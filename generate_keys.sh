#!/usr/bin/env sh

set -e


if [ $# -eq 0 ] && [ ! -d "tiller-keys" ]; then
    echo "Creating keys in folder tiller-keys"
    echo "This might take a while..."
    mkdir -p tiller-keys
    openssl genrsa -out tiller-keys/ca.key.pem 4096
    openssl genrsa -out tiller-keys/tiller.key.pem 4096
    openssl genrsa -out tiller-keys/helm.key.pem 4096

    openssl req -key tiller-keys/ca.key.pem -new -x509 -days 7300 -sha256 -out tiller-keys/ca.cert.pem -extensions v3_ca -subj "/C=FOOCOUNTRY/ST=FOOSTATE/L=FOOCITY/O=FOOORGANIZATION/OU=FOOOUNIT/CN=FOODOMAIN" -config ./pssl.cnf
    openssl req -key tiller-keys/tiller.key.pem -new -sha256 -out tiller-keys/tiller.csr.pem  -subj "/C=FOOCOUNTRY/ST=FOOSTATE/L=FOOCITY/O=FOOORGANIZATION/OU=FOOOUNIT/CN=FOODOMAIN" -config ./pssl.cnf
    openssl req -key tiller-keys/helm.key.pem -new -sha256 -out tiller-keys/helm.csr.pem  -subj "/C=FOOCOUNTRY/ST=FOOSTATE/L=FOOCITY/O=FOOORGANIZATION/OU=FOOOUNIT/CN=FOODOMAIN" -config ./pssl.cnf

    openssl x509 -req -CA tiller-keys/ca.cert.pem -CAkey tiller-keys/ca.key.pem -CAcreateserial -in tiller-keys/tiller.csr.pem -out tiller-keys/tiller.cert.pem
    openssl x509 -req -CA tiller-keys/ca.cert.pem -CAkey tiller-keys/ca.key.pem -CAcreateserial -in tiller-keys/helm.csr.pem -out tiller-keys/helm.cert.pem
    echo "\033[32mKeys generated. Secure them somewhere.\033[0m"
elif [ ! -d "tiller-keys-${1}" ]; then
    echo "Creating keys in folder tiller-keys-${1}"
    echo "This might take a while..."
    mkdir -p tiller-keys-${1}
    openssl genrsa -out tiller-keys-${1}/ca.key.pem 4096
    openssl genrsa -out tiller-keys-${1}/tiller.key.pem 4096
    openssl genrsa -out tiller-keys-${1}/helm.key.pem 4096

    openssl req -key tiller-keys-${1}/ca.key.pem -new -x509 -days 7300 -sha256 -out tiller-keys-${1}/ca.cert.pem -extensions v3_ca -subj "/C=FOOCOUNTRY/ST=FOOSTATE/L=FOOCITY/O=FOOORGANIZATION/OU=FOOOUNIT/CN=FOODOMAIN" -config ./pssl.cnf
    openssl req -key tiller-keys-${1}/tiller.key.pem -new -sha256 -out tiller-keys-${1}/tiller.csr.pem  -subj "/C=FOOCOUNTRY/ST=FOOSTATE/L=FOOCITY/O=FOOORGANIZATION/OU=FOOOUNIT/CN=FOODOMAIN" -config ./pssl.cnf
    openssl req -key tiller-keys-${1}/helm.key.pem -new -sha256 -out tiller-keys-${1}/helm.csr.pem  -subj "/C=FOOCOUNTRY/ST=FOOSTATE/L=FOOCITY/O=FOOORGANIZATION/OU=FOOOUNIT/CN=FOODOMAIN" -config ./pssl.cnf

    openssl x509 -req -CA tiller-keys-${1}/ca.cert.pem -CAkey tiller-keys-${1}/ca.key.pem -CAcreateserial -in tiller-keys-${1}/tiller.csr.pem -out tiller-keys-${1}/tiller.cert.pem
    openssl x509 -req -CA tiller-keys-${1}/ca.cert.pem -CAkey tiller-keys-${1}/ca.key.pem -CAcreateserial -in tiller-keys-${1}/helm.csr.pem -out tiller-keys-${1}/helm.cert.pem
    echo "\033[32mKeys generated. Secure them somewhere.\033[0m"
else
    echo "Folder for keys found. Not creating new keys."
fi