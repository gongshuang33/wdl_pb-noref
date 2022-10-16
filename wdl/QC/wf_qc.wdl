version 1.0

import "tasks/qc.wdl" as qc

workflow RunQC {
    input {
        String? sample_txt # 二代数据
        String workdir
        String scriptDir

        # Map[String, String] dockerImages
    }

    Array[Array[String]] sample_fqs = read_tsv(sample_group)

	if(defined(sample_txt)) {
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
	}
	output {
			String qc_stat_xls = QcStat.qc_stat_xls
			Array[String] fq_lists = QcStat.fq_lists # 用于NGScorrection做校正
		}
    
}