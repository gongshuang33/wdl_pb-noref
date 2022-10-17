version 1.0

import './tasks/NGScorrect.wdl' as  NGSCorrect

workflow RunNGScorrect {
	input {
		String workdir
		String scriptDir
		Array[String]? fq_lists  # 来自QC
		String all_polished_fa 	# 来自ClusterTask

		String? sample_txt # 二代数据
	}

	if(defined(sample_txt)) { # 有二代数据则进行校正
		call NGSCorrect.NGScorrectTask as NGS {
			input:
				workdir = workdir,
				scriptDir = scriptDir,
				fq_lists = fq_lists,
				all_polished_fa = all_polished_fa
		}
	}

	output {
			String? NGS_corrected_fasta = NGS.NGS_corrected_fasta
	}

	

	

	
}