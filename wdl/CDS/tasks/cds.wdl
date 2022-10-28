version 1.0

task CDSTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta  
		String polished_hq_fasta 
		String cdhit_isoforms_fasta #/CDhit/cd-hit.isoforms.fasta
		String good_fasta  # NGS_corrected.fasta or Isoseq.polished_hq_fasta

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String cds_dir = workdir + "/CDS"
	command <<<
		mkdir -p ~{cds_dir} && cd ~{cds_dir}
		if [ -f 'run_cds_done' ];then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{cds_dir}
		~{scriptDir}/make_train.py --hq ~{polished_hq_fasta} --cor ~{good_fasta} --top 200 --out train.fasta
		export PATH=/export/personal/pengh/Software/cdhit:$PATH
		export PYTHONPATH=/export/pipeline/RNASeq/python3package/:/export/pipeline/RNASeq/Software/ANGEL/v3.0/ANGEL/lib/python3.6/site-packages/

		/export/pipeline/RNASeq/Software/ANGEL/v3.0/ANGEL/bin/dumb_predict.py train.fasta train --min_aa_length 100 --cpus 20
		/export/pipeline/RNASeq/Software/ANGEL/v3.0/ANGEL/bin/angel_make_training_set.py train.final train.final.training --random --cpus 20
		/export/pipeline/RNASeq/Software/ANGEL/v3.0/ANGEL/bin/angel_train.py train.final.training.cds train.final.training.utr train.final.classifier.pickle --cpus 2
		/export/pipeline/RNASeq/Software/ANGEL/v3.0/ANGEL/bin/angel_predict.py --cpus 20 ~{cdhit_isoforms_fasta} train.final.classifier.pickle Final.predict --output_mode best --min_dumb_aa_length 100
		rm -rf ANGEL.tmp.*

		python ~{scriptDir}/seq_length_stat.py --fasta Final.predict.ANGEL.cds > Final.predict.ANGEL.cds.len.stat
		Rscript ~{scriptDir}/len_distribution.R Final.predict.ANGEL.cds.len.stat CDS_length_distribution.pdf Read_Length Read_Number
		convert CDS_length_distribution.pdf CDS_length_distribution.png
		~{scriptDir}/remove_CDS.py ~{cdhit_isoforms_fasta} Final.predict.ANGEL.cds
		touch run_cds_done
		date
		" > run_cds.sh
		bash run_cds.sh > run_cds_STDOUT 2> run_cds_STDERR
	>>>

	output {
		String dir = cds_dir
		String cds_removed_isoform_fasta = cds_dir + "/cds_removed_isoform.fasta"
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}