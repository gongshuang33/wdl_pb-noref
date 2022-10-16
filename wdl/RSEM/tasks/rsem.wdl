version 1.0

#无参定量 - 需要二代数据

task RSEMPreTask {
	input {
		String workdir
		String scriptDir
		String cdhit_togene  #CDhit.togene
		String cd-hit_isoforms_fasta #cdhit.cd-hit_isoforms_fasta
		
		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String rsem_dir = workdir + '/RSEM'

	command <<<
		set -exit
		date
		mkdir -p ~{rsem_dir} && cd ~{rsem_dir}
		if [ -f 'rsem_dir' ];then
			exit 0
		fi

		mkdir ~{rsem_dir}/tmp
		/export/personal/pengh/Software/RSEM-master/rsem-prepare-reference --transcript-to-gene-map ~{cdhit_togene} --bowtie2 --bowtie2-path /export/personal/pengh/Software/bowtie2-2.3.2-legacy/ ~{cd-hit_isoforms_fasta} ~{rsem_dir}/tmp/isoforms
		touch RSEM_pre_done
		date
	>>>

	output {
		String dir = rsem_dir
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task RSEMTask {
	input {

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
	
	>>>

	output {

	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}

}

task RSEMStatTask {
	input {
		String rsem_dir
		String scriptDir
		String sample_txt

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -vex
		hostname
		date
		cd ~{rsem_dir}
		if [ -f 'RSEM_stat_done' ];then
			exit 0
		fi
		python ~{scriptDir}/merge_rsem.py
		python ~{scriptDir}/merge_rsem_transcript.py
		perl ~{scriptDir}/mapping_rate_trans_v5.pl -n Dc-A-1,Dc-A-2,Dc-A-3,Dc-B-1,Dc-B-2,Dc-B-3,Dc-C-1,Dc-C-2,Dc-C-3

		cut -f 1-2 ~{sample_txt} > grouplist
		mv samples.fpkm.xls samples.fpkm.xls_bak
		python ~{scriptDir}/re_order_sample_fpkm.py
		rm samples.fpkm.xls_bak

		mkdir ~{rsem_dir}/fpkm_visualization
		Rscript ~{scriptDir}/fpkm_visualization_v3.R ~{rsem_dir}/samples.fpkm.xls ~{rsem_dir}/grouplist ~{rsem_dir}/fpkm_visualization

		touch RSEM_stat_done
		date

	>>>

	output {

	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}