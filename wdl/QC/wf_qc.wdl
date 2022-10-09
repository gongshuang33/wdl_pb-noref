version 1.0

import "tasks/qc.wdl" as qc

workflow RunQC {
    input {
        File sample_txt
        String workdir
        String scriptDir

        Map[String, String] dockerImages
    }

    Array[Array[String]] sample_fqs = read_tsv(sample_group)

    scatter (smp in sample_fqs) {
        call qc.QcTask as Qc {
            input:
                projectdir = projectdir,
                sampleName = smp[0],
                read1 = smp[1],
                read2 = smp[2],
                scriptDir = scriptDir,
                # image = dockerImages["QC"]
        }
    }

    call qc.QcStatTask as QcStat {
        input:
            qc_dirs = Qc.qc_dir,
            sample_txt = sample_txt,
            scriptDir = scriptDir,
            # image = dockerImages["QC"]
    }

    output {
        Array[Array[String]] sample_clean_fqs = Qc.sample_clean_fqs
        String qc_stat_xls = QcStat.qc_stat_xls
    }
}