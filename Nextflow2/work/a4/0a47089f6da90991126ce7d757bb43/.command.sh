#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family2.fam --score hapmap1Family2.fam.assocSqueezed.assoc --out hapmap1Family2
