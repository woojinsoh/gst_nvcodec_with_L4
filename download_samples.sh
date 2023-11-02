#!/bin/bash

FILENAME="4k_avc.mp4"
FILEID="1yr4W3LEH1ps_PkMS3Rwxol6Kulf5tyHS"

wget --load-cookies ~/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies ~/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=${FILEID}' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=${FILEID}" -O ${FILENAME} && rm -rf ~/cookies.txt

~                                                                                                                                                              
