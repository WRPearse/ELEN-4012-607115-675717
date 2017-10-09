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
      set file(params.input_pat+"Family*.fam") into families_ch1
   script:
    setName = params.input_pat
    noFolds = params.no_folds
    workDir = params.input_dir
    template "kFold.py"
}

input_ch = Channel.create()
Channel
    .from(file(bed),file(bim),file(fam))
    .buffer(size:3)
    .map { a -> [checker(a[0]), checker(a[1]), checker(a[2])] }
    .separate( input_ch ) { a -> [a,a] }

process associationTest {
   echo true
   family = params.input_pat+"Family*"
   input:
    set file(params.input_pat+'.bed'),file(params.input_pat+'.bim'),file(params.input_pat+'.fam') from input_ch
    each file(family) from families_ch1

   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      set file(params.input_pat+"*.assoc") into assoc_ch
   script:
   setName = params.input_pat
   fileNameStr = family.getName()
   assocFile = fileNameStr.replaceFirst(/.fam/,"")
   """
   plink --bfile $setName --assoc --allow-no-sex --remove-fam ${family} --out $assocFile
   """
}

process squeeze {
   echo true
   familyAssoc = params.input_pat+"Family*.assoc"
   input:
    set file(familyAssoc) from assoc_ch
   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file(params.input_pat+"*Squeezed.assoc") into squeeze_ch
   script:
   fileNameStr = familyAssoc.getName()
   squeezeFile = fileNameStr.replaceFirst(/.assoc/,"")
   """
   tr -s \\  < ${familyAssoc} > ${squeezeFile}Squeezed.assoc
   """
}

process makeScoreFile {
   echo true
   fileName = params.input_pat+"*.assoc"
   input:
    file(fileName) from squeeze_ch
   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file(params.input_pat+"*.score") into score_ch
   script:
   fileNameStr = fileName.getName()
   scoreFile = fileNameStr.replaceFirst(/Squeezed.assoc/,"")
   """
   cut -f 3,5,11 -d\\  ${fileName} >  ${scoreFile}.score
   """
}

input_ch2 = Channel.create()
Channel
    .from(file(bed),file(bim),file(fam))
    .buffer(size:3)
    .map { a -> [checker(a[0]), checker(a[1]), checker(a[2])] }
    .separate( input_ch2 ) { a -> [a,a] }

process scoreFamily {
   echo true
   scoreFile = params.input_pat+"*.score"

   input:
    set file(params.input_pat+'.bed'),file(params.input_pat+'.bim'),file(params.input_pat+'.fam') from input_ch2
    each file(scoreFile) from score_ch
    family = Channel.fromPath(params.output_dir + "/*.fam")
    set file(families) from family

   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file(params.input_pat+"Family*.profile") into result_ch
   script:
   setName = params.input_pat
   fileNameStr = scoreFile.getName()
   famFile = fileNameStr.replaceFirst(/.score/,".fam")
   outFile = fileNameStr.replaceFirst(/.score/,"")
   """
   plink --bfile $setName --keep-fam $famFile --score $scoreFile --out $outFile
   """
}

//Channel.from(result_ch).subscribe onComplete { println "Cross training complete!!!" }
