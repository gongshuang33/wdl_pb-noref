version 1.0

task QcTask {
	input {
		String workdir
		String sampleName
		String read1
		String read2
		String scriptDir

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = '/export/'
	}

	String dir = workdir + '/QC/${sampleName}'

	command {
		set -ex

		mkdir -p ${dir} && cd ${dir}

		if [ -f 'qc.done' ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ${dir}
		fastp -i ${read1} -o ${sampleName + '.clean.R1.fq.gz'} \
			-I ${read2} -O ${sampleName + '.clean.R2.fq.gz'} \
			-h ${sampleName + '.QC.report.html'} -j ${sampleName + '.QC.report.json'} -w ${cpu}

		fastqc -t ${cpu} --extract -o . ${sampleName + '.clean.R1.fq.gz'} ${sampleName + '.clean.R2.fq.gz'}

		python3 ${scriptDir + '/plot_fastqc.py'} \
			-1 ${sampleName + '.clean.R1_fastqc/fastqc_data.txt'} \
			-2 ${sampleName + '.clean.R2_fastqc/fastqc_data.txt'} \
			--name ${sampleName}

		rm *_fastqc.zip

		touch qc.done
		date
		" > run_qc_${sampleName}.sh 
		bash run_qc_${sampleName}.sh > run_qc_${sampleName}_STDOUT 2> run_qc_${sampleName}_STDERR
	}
		
	String fq1 = dir + '/${sampleName}.clean.R1.fq.gz'
	String fq2 = dir + '/${sampleName}.clean.R2.fq.gz'

	output {
		Array[String] sample_clean_fqs = [sampleName, fq1, fq2]
		# String qc_dir = basename(dir, sampleName)
		String qc_dir = workdir + '/QC'

	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task QcStatTask {
	input {
		Array[String]+ qc_dirs
		String? sample_txt
		String scriptDir

		# Int cpu = 1
		# String memgb = '2G'
		# String image

		String? ROOTDIR = '/export/'
	}

	String qc_dir = select_first(qc_dirs)

	command {
		set -ex

		mkdir -p ${qc_dir} && cd ${qc_dir}

		if [ -f 'qc_stat.done' ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ${qc_dir}
		mkdir -p QC_result
		cp */*.base_quality.png QC_result/
		cp */*.base_quality.pdf QC_result/
		cp */*.base_content.png QC_result/
		cp */*.base_content.pdf QC_result/

		python3 ${scriptDir + '/stat_fastp.py'} ${sample_txt} ${qc_dir}

		#汇总质控后的所有fq结果到一个文件
		ls ~{qc_dir}/*/*.fastq.gz > fq_list

		touch qc_stat.done
		date
		" > run_qc_stat.sh
		bash run_qc_stat.sh > run_qc_stat_STDOUT 2> run_qc_stat_STDERR
	}

	File fq_list = qc_dir + '/fq_list'

	output {
		File qc_stat_xls = qc_dir + '/QC_stat.xls'
		Array[String] fq_lists = read_lines(fq_list) #传给NGScorrection
	}

	# runtime {
	#	 docker: image
	#	 cpu: cpu
	#	 memory: memgb
	#	 root: ROOTDIR
	# }
}