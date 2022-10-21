version 1.0

#无参定量 - 需要二代数据

task RSEMPreTask {
	input {
		String workdir
		String scriptDir
		String cdhit_togene  #CDhit.togene
		String cdhit_isoforms_fasta #cdhit.cdhit_isoforms_fasta
		
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
		/export/personal/pengh/Software/RSEM-master/rsem-prepare-reference --transcript-to-gene-map ~{cdhit_togene} --bowtie2 --bowtie2-path /export/personal/pengh/Software/bowtie2-2.3.2-legacy/ ~{cdhit_isoforms_fasta} ~{rsem_dir}/tmp/isoforms
		touch RSEM_pre_done
		date
	>>>

	output {
		String dir = rsem_dir
		String rsem_isoforms = rsem_dir + '/tmp/isoforms'
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
		String workdir
		String rsem_dir
		String rsem_isoforms
		Array[String] sample_clean_fqs # [samplename, fq1,fq2]

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String sample = sample_clean_fqs[0]
	String sample_dir = rsem_dir + '/' + sample
	String sample_R1_fq = sample_clean_fqs[1]
	String sample_R2_fq = sample_clean_fqs[2]

	command <<<
		set -vex
		hostname
		date
		mkdir -p ~{sample_dir} && cd ~{sample_dir}
		if [ -f 'RSEM_~{sample}_done' ];then
			exit 0
		fi
		/usr/bin/perl /export/personal/pengh/Software/RSEM-master/rsem-calculate-expression --bowtie2 --bowtie2-path /export/personal/pengh/Software/bowtie2-2.3.2-legacy/ --paired-end ~{sample_R1_fq} ~{sample_R2_fq} -p 10 ~{rsem_isoforms} ~{sample_dir}/~{sample}

		rm ~{sample_dir}/~{sample}.transcript.bam
		touch ~{sample_dir}/RSEM_~{sample}_done
		date
	>>>

	output {
		String samplename = sample
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
		String? sample_txt
		Array[String] samples  # RSEMTask.samplename

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
		perl ~{scriptDir}/mapping_rate_trans_v5.pl -n ~{sep=', ' samples}

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
		String gene_count = rsem_dir +  '/samples.readcount.xls'
		String gene_fpkm = rsem_dir +  '/samples.fpkm.xls'
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}