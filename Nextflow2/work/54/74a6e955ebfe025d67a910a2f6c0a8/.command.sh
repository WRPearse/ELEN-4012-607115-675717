#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family9.fam --score hapmap1Family9.fam.assocSqueezed.assoc.score --out hapmap1Family9
