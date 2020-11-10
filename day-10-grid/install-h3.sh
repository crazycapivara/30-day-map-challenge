#!/bin/bash
wget https://raw.githubusercontent.com/crazycapivara/h3-r/master/install-h3c.sh

# Install H3 C library
chmod +x install-h3c.sh
./install-h3c.sh

# Installl H3 for R
R -q -e 'remotes::install_github("crazycapivara/h3-r")'
