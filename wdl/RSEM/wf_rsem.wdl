version 1.0

import './tasks/rsem.wdl' as rsem

workflow RunRSEM {
	input {
		String workdir
		String scriptDir
		String cdhit_togene
		String cdhit_isoforms_fasta
		String? sample_txt
		Array[Array[String]]? sample_clean_fqs  #QC.sample_clean_fqs

		# Map[String, String] dockerImages
	}

	call rsem.RSEMPreTask as RSEMPre {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			cdhit_togene = cdhit_togene,
			cdhit_isoforms_fasta = cdhit_isoforms_fasta,
			# image = dockerImages["QC"]
	}
	if(defined(sample_clean_fqs)) {
		scatter(line in sample_clean_fqs) {
			call rsem.RSEMTask as RSEM {
				input:
					workdir = workdir,
					rsem_dir = RSEMPre.dir,
					rsem_isoforms = RSEMPre.rsem_isoforms,
					sample_clean_fqs = line,
					# image = dockerImages["QC"]
			}
	}

	call rsem.RSEMStatTask as RSEMStat {
		input:
			rsem_dir = RSEMPre.dir,
			scriptDir = scriptDir,
			sample_txt = sample_txt,
			samples = RSEM.samplename,
			# image = dockerImages["QC"]
	}
	}
	
}