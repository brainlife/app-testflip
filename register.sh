#!/bin/bash

cat $(jq -r .bvecs config.json) | tr ',' ' ' > bvecs
cat $(jq -r .bvals config.json) | tr ',' ' ' > bvals

echo "fsl/running bet2"
bet2 $(jq -r .dwi config.json) dwi.bet -m 
echo "dtifit to generate FA to register it to FMRIB58_FA_1mm.nii.gz template"
dtifit -k $(jq -r .dwi config.json) -o dwi.dtifit -m dwi.bet_mask.nii.gz -r bvecs -b bvals -w 
flirt -in dwi.dtifit_FA.nii.gz -ref $FSLDIR/data/standard/FMRIB58_FA_1mm.nii.gz -omat fa.xfm -dof 12 

echo "converting from 12 to 6 dof"
aff2rigid fa.xfm fa6.xfm

echo "now registering dwi to mni"
flirt -in $(jq -r .dwi config.json) -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -o dwi_mni.nii.gz -applyxfm -init fa6.xfm 

echo "rotating bvecs"
./bvecs_rotate_xfm.sh $(jq -r .bvecs config.json) dwi.bvecs fa6.xfm

