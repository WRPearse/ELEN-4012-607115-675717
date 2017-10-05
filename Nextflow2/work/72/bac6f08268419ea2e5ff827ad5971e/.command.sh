#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family1.fam --score hapmap1Family1.fam.assocSqueezed.assoc --out hapmap1Family1
