subs, = glob_wildcards("data/lesions/sub-{subject}_lesionMask.nii.gz") 


rule all:
    input:
        expand("data/disco/sub-{sub}", sub=subs[0])

rule create_tempfolders:
    input:
        "data/reslice/sub-{subject}_lesionMask_1mmreslice_bin.nii.gz"
    output:
        "data/bcb_input_tmp/sub-{subject}/sub-{subject}_lesionMask.nii.gz",
        directory("data/bcb_input_tmp/sub-{subject}/")
    shell:
        '''
        cp {input} {output[0]}
        '''

rule register_1mm:
    input:
        "data/lesions/sub-{subject}_lesionMask.nii.gz"
    output:
        "data/reslice/sub-{subject}_lesionMask_1mmreslice.nii.gz"
    shell:
        '''
        flirt -in {input} -ref ${{FSLDIR}}/data/standard/MNI152_T1_1mm_brain.nii.gz -datatype float -interp spline -applyxfm -usesqform -out {output}
        '''

rule binarize:
    input:
        "data/reslice/sub-{subject}_lesionMask_1mmreslice.nii.gz"
    output:
        "data/reslice/sub-{subject}_lesionMask_1mmreslice_bin.nii.gz"
    shell:
        '''
        fslmaths {input} -bin {output} -odt short
        '''


rule disco:
    input:
        "data/bcb_input_tmp/sub-{subject}/sub-{subject}_lesionMask.nii.gz"
    output:
        directory("data/disco/sub-{subject}")
    shell:
        '''
        mkdir {output}
        mkdir {output}/logs
        sh /data/nimlab/toolkits/BCBToolKit/Tools/scripts/disco178.sh $(readlink -f {input}) $(readlink -f {output}) 0
        '''
