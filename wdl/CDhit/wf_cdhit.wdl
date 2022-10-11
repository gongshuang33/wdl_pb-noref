version 1.0

import 'tasks/cdhit_ngs.wdl' as cdhit_ngs 
import 'tasks/cdhit_no_ngs.wdl' as cdhit_no_ngs

workflow RunCDhit {
	input {
		String workdir
		String scriptDir
		String? NGS_corrected_fasta		# 二代数据
		String? all_polished_fa 		# Isoseq -> cluster
		#Map[String, String] dockerImages
		String pipline_type  
	}

	if (pipline_type == '3') {
		call cdhit_no_ngs.CDhitTask as CDhit{
			input:
				workdir = workdir,
				scriptDir = scriptDir,
				NGS_corrected_fasta = NGS_corrected_fasta,
				#image = dockerImages[""]
		}
	}

	if (pipline_type == '3+2') {
		call cdhit_ngs.CDhitTask as CDhit{
			input:
				workdir = workdir,
				scriptDir = scriptDir,
				all_polished_fa = all_polished_fa,
				#image = dockerImages[""]
		}
	}


	output {
		String unigene_fasta = CDhit.unigene_fasta
	}
}
