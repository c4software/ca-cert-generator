#!/bin/bash

DOMAIN=$1
if [[ -z "$DOMAIN" ]]; then
  echo 'Un domaine doit être spécifé.'
  exit 1
fi

ROOTCA_CRT="./output/rootCA/rootCA.crt"
ROOTCA_KEY="./output/rootCA/rootCA.key"
if [[ ! -f "$ROOTCA_CRT" ]]; then
  echo "Vous devez générer une CA pour utiliser le script"
  exit 1
fi

if [[ ! -f "$ROOTCA_KEY" ]]; then
  echo "Vous devez générer une CA pour utiliser le script"
  exit 1
fi


mkdir "$DOMAIN"
cd "$DOMAIN"


# Création du fichier ext pour les alt-names
cat <<EOM >$DOMAIN.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1        = $DOMAIN
EOM

cat <<EOM >$DOMAIN.cnf
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=FR
ST=France
L=Angers
O=Brosseau
OU=Brosseau
emailAddress=c4software@gmail.com
CN=$DOMAIN
EOM

# Génération du script de regenration
cat <<EOM >generate.sh
#!/bin/bash

openssl x509 -req -in $DOMAIN.csr -CA .$ROOTCA_CRT -CAkey .$ROOTCA_KEY -CAcreateserial -out $DOMAIN.crt -days 10000 -extfile $DOMAIN.ext
EOM
chmod +x generate.sh

# Création de la Server Key
openssl req -new -sha256 -nodes -out $DOMAIN.csr -newkey rsa:2048 -keyout $DOMAIN.key -config <( cat $DOMAIN.cnf )

# Génération final du certificat
./generate.sh

# Affichage configuration
echo ""
echo ""
echo "======================="
echo "= Certificat Généré ! ="
echo "======================="
echo ""
echo ""
echo "Configuration pour le vhost apache :

<VirtualHost *:443>

  […]

  SSLEngine on
  SSLCertificateFile /etc/apache2/ssl.crt/$DOMAIN.crt 
  SSLCertificateKeyFile /etc/apache2/ssl.crt/$DOMAIN.key

  Header unset Strict-Transport-Security
  Header always set Strict-Transport-Security \"max-age=0;includeSubDomains\"

  […]
</VirtualHost>"
