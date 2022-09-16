version 1.0

import 'tasks/subreads.wdl' as subreads

workflow RunSubreads {
	input {
		String workdir
		String scriptDir

		Array[Array[String]] movie_bams	#[[movie1, bam1],[movie2, bam2], [...], ...]
		#Map[String, String] dockerImages
		

	}
	scatter (i in movie_bams) {
		call subreads.SubreadsTask {
			input:
				workdir = workdir,
				movie = i[0],	# movie号
				bam	= i[1],	# bam文件的绝对路径
				scriptDir = scriptDir,
				#image = dockerImages,
		}
	}

	call subreads.SubreadsStatTask {
		input:
			workdir = workdir,
			samples = SubreadsTask.subreads_bam,
			subreads_dir = SubreadsTask.dir[0],
			#image = dockerImages,
	}

	output {
        String Post_Filter_Polymerase_reads_summary_xls = SubreadsStatTask.summary_xls
    }




}
