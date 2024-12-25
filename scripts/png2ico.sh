#/bin/bash

# Dependências
# convert do imagemagick: https://imagemagick.org/index.php

# https://superuser.com/questions/227736/how-do-i-convert-a-png-into-a-ico
sizes="16 32 48 128 256"

for size in $sizes
do
  convert design-stuff/logo.png -scale "$size" -strip design-stuff/logo@"$size".png
done

convert design-stuff/logo@* public/favicon.ico

rm design-stuff/logo@*
