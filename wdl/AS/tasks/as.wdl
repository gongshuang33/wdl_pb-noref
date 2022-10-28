version 1.0

task ASTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta
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
		echo "
		set -vex 
		hostname
		date
		cd ~{as_dir}
		python ~{scriptDir}/AS_24.py ~{cdhit_dir}/new_clstr.stat.xls ~{unigene_fasta} ~{cdhit_dir}/new_cdhit1.fasta.clstr
		Rscript ~{scriptDir}/histogram_AS.R Unigene.AS_Event_Number.xls.dis
		touch run_as_done
		date
		" > run_as.sh
		bash run_as.sh > run_as_STDOUT 2> run_as_STDERR
	>>>

	output {}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}