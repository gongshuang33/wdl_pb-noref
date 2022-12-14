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

	if(defined(sample_txt)) {
		call rsem.RSEMPreTask as RSEMPre {
			input:
				workdir = workdir,
				scriptDir = scriptDir,
				cdhit_togene = cdhit_togene,
				cdhit_isoforms_fasta = cdhit_isoforms_fasta,
				# image = dockerImages["QC"]
		}

		scatter(line in select_first([sample_clean_fqs])) {
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
				# image = dockerImages[""]
		}
		
	}
	
	output {
		String? diff_dir = workdir + '/Diff'
		String? gene_count = RSEMStat.gene_count
		String? gene_fpkm = RSEMStat.gene_fpkm
	}
	
}