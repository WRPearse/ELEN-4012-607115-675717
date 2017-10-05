#!/bin/bash -ue
plink --bfile hapmap1 --assoc --allow-no-sex --remove-fam hapmap1Family10.fam --out hapmap1Family10.fam
