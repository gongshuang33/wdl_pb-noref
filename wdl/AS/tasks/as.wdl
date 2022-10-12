version 1.0

task ASTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta  #cdhit.unigene_fasta
		String cdhit_dir

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String as_dir = workdir + '/AS'

	command <<<
		set -ex
		date
		mkdir -p ~{as_dir} && cd ~{as_dir}
		if [ -f 'run_as_done' ];then
			exit 0
		fi
		python ~{scriptDir}AS_24.py ~{cdhit_dir}/new_clstr.stat.xls ~{unigene_fasta} ~{cdhit_dir}/new_cdhit1.fasta.clstr
		/export/pipeline/RNASeq/Software/R/R_3.5.1/bin/Rscript ~{as_dir}/histogram_AS.R Unigene.AS_Event_Number.xls.dis
		touch run_as_done
		date
	>>>
}