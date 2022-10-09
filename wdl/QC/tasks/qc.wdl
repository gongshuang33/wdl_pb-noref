version 1.0

task QcTask {
    input {
        String workdir
        String sampleName
        String read1
        String read2
        String scriptDir

        # Int cpu = 8
        # String memgb = '16G'
        # String image

        String? ROOTDIR = "/export/"
    }

    String dir = workdir + "/QC/${sampleName}"

    command {
        set -ex

        mkdir -p ${dir} && cd ${dir}

        if [ -f "qc.done" ]; then
            exit 0
        fi

        fastp -i ${read1} -o ${sampleName + ".clean.R1.fq.gz"} \
            -I ${read2} -O ${sampleName + ".clean.R2.fq.gz"} \
            -h ${sampleName + ".QC.report.html"} -j ${sampleName + ".QC.report.json"} -w ${cpu}

        fastqc -t ${cpu} --extract -o . ${sampleName + ".clean.R1.fq.gz"} ${sampleName + ".clean.R2.fq.gz"}

        python3 ${scriptDir + "/plot_fastqc.py"} \
            -1 ${sampleName + ".clean.R1_fastqc/fastqc_data.txt"} \
            -2 ${sampleName + ".clean.R2_fastqc/fastqc_data.txt"} \
            --name ${sampleName}

        rm *_fastqc.zip

        touch qc.done
    }
    
    String fq1 = dir + "/${sampleName}.clean.R1.fq.gz"
    String fq2 = dir + "/${sampleName}.clean.R2.fq.gz"

    output {
        Array[String] sample_clean_fqs = [sampleName, fq1, fq2]
        String qc_dir = basename(dir, sampleName)
    }

    # runtime {
    #     docker: image
    #     cpu: cpu
    #     memory: memgb
    #     root: ROOTDIR
    # }
}

task QcStatTask {
    input {
        Array[String]+ qc_dirs
        File sample_txt
        String scriptDir

        # Int cpu = 1
        # String memgb = '2G'
        # String image

        String? ROOTDIR = "/export/"
    }

    String qc_dir = select_first(qc_dirs)

    command {
        set -ex

        mkdir -p ${qc_dir} && cd ${qc_dir}

        if [ -f "qc_stat.done" ]; then
            exit 0
        fi

        mkdir -p QC_result
        cp */*.base_quality.png QC_result/
        cp */*.base_quality.pdf QC_result/
        cp */*.base_content.png QC_result/
        cp */*.base_content.pdf QC_result/

        python3 ${scriptDir + "/stat_fastp.py"} \
            ${sample_group} ${qc_dir}

        touch qc_stat.done
    }

    output {
        File qc_stat_xls = qc_dir + "/QC_stat.xls"
    }

    # runtime {
    #     docker: image
    #     cpu: cpu
    #     memory: memgb
    #     root: ROOTDIR
    # }
}