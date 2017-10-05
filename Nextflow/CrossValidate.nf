#!/usr/bin/env nextflow

//---- General definitions --------------------------------------------------//

import java.nio.file.Paths

params.work_dir   = "$HOME/Documents/Nextflow"
params.input_dir  = "${params.work_dir}/input"
params.output_dir = "${params.work_dir}/output"

params.input_pat  = 'hapmap1'

params.no_folds = 10

params.plink_process_memory = '750MB' // how much plink needs for this
params.other_process_memory = '750MB' // how much other processed need

max_plink_cores = params.max_plink_cores = 1

plink_mem_req = params.plink_process_memory
other_mem_req = params.other_process_memory

//---- Modification of variables for pipeline -------------------------------//

// Checks if the file exists
checker = { fn ->
   if (fn.exists())
       return fn;
    else
       error("\n\n-----------------\nFile $fn does not exist\n\n---\n")
}

bed = Paths.get(params.input_dir,"${params.input_pat}.bed").toString()
bim = Paths.get(params.input_dir,"${params.input_pat}.bim").toString()
fam = Paths.get(params.input_dir,"${params.input_pat}.fam").toString()

process generateFolds {
   echo true
   input:
    set file(params.input_pat+'.fam') from params.input_dir
   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      set file(params.input_pat+"Family*.fam") into families_ch
   script:
    setName = params.input_pat
    noFolds = params.no_folds
    workDir = params.input_dir
    template "kFold.py"
}

process associationTest {
   echo true
   input:
    set file(params.input_pat+'.bed'),file(params.input_pat+'.bim') from params.input_dir
    set "family*.fam" from families_ch

   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file("family${x}assoc.assoc") into assoc_ch
   script:
   """
   plink --bfile cleaned --threads 1 --assoc --out association
   """
}

process squeeze {
   echo true
   input:
    file('association.assoc') from assoc_ch
   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file("squeezedAssoc.assoc") into squeeze_ch
   script:
   """
   tr -s \\  < association.assoc > squeezedAssoc.assoc
   """
}

process makeScoreFile {
   echo true
   input:
    file('squeezedAssoc.assoc') from squeeze_ch
   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file("assocScorer.score") into score_ch
   script:
   """
   dir;
   cut -f 3,5,11 -d\\  squeezedAssoc.assoc >  assocScorer.score
   """
}
/*
process scoreFamily {
   echo true
   input:
    file('assocScorer.score') from score_ch
    set file('cleaned.bed'),file('cleaned.bim'),file('cleaned.fam') from input_ch3

   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file("familyScore.profile") into result_ch
   script:
   """
   plink --bfile cleaned --score assocScorer.score --out familyScore
   """
}*/

//Channel.from(result_ch).subscribe onComplete { println "Cross trainign complete!!!" }
