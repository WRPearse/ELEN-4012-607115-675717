#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family4.fam --score hapmap1Family4.fam.assocSqueezed.assoc.score --out hapmap1Family4
