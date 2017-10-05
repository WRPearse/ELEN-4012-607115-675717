#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family10.fam --score hapmap1Family10.fam.assocSqueezed.assoc --out hapmap1Family10
