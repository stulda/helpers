#!/bin/bash

# Convert a .pfx file to .pem and .key files

pfxFile=$1
pfxPassword=$2

# check if openssl is installed
if ! [ -x "$(command -v openssl)" ]; then
    echo "Error: openssl is not installed."
    exit 1
fi

# check if pfx-file and pfx-password are provided
if [ $# -ne 2 ]; then
    echo "Usage: ./convert-pfx-to-pem-key.sh <pfx-file> <pfx-password>"
    exit 1
fi

# check if pfx-file exists
if [ ! -f $pfxFile ]; then
    echo "Error: $pfxFile does not exist."
    exit 1
fi

# new filenames
keyFile="${pfxFile%.*}.key"
pemFile="${pfxFile%.*}-crt.pem"
caPemFile="${pfxFile%.*}-ca.pem"
fullPemFile="${pfxFile%.*}-full.pem"

# convert pfx to pem and key files
openssl pkcs12 -in $pfxFile -clcerts -nokeys -password pass:$pfxPassword | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $pemFile
openssl pkcs12 -in $pfxFile -cacerts -nokeys -chain -password pass:$pfxPassword | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $caPemFile
openssl pkcs12 -in $pfxFile -nocerts -nodes -password pass:$pfxPassword | sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' > $keyFile

# remove passphrase from keyfile"
openssl rsa -in $keyFile -out $keyFile > /dev/null 2>&1

# combine cert and ca cert to -full.pem
cat  $pemFile $caPemFile > $fullPemFile
