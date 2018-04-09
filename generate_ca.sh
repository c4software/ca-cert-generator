#!/bin/bash

ROOTCA="./output/rootCA"
ROOTCA_CRT="$ROOTCA/rootCA.crt"
ROOTCA_KEY="$ROOTCA/rootCA.key"

if [[ -d "$ROOTCA" ]]; then
  echo "La CA existe déjà. Pour continuer, supprimer le dossier « $ROOTCA »"
  exit 1
fi

mkdir "$ROOTCA"

# Génération de la Root Key. (ajouter -des3 pour avoin un mot de passe).
openssl genrsa -out $ROOTCA_KEY 4096

# Génération de la RootCA
openssl req -x509 -new -nodes -key $ROOTCA_KEY -sha256 -days 10000 -out $ROOTCA_CRT -subj "/C=FR/ST=Maine-et-Loire/L=Angers/O=vbrosseau/OU=IT"
