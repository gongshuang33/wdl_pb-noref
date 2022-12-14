version 1.0

task SSRTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta  # wf_cdhit.unigene_fasta

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String ssr_dir = workdir + "/SSR"
	command <<<
		set -ex
		date
		mkdir -p ~{ssr_dir} && cd ~{ssr_dir} 
		if [ -f 'SSR_done' ];then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{ssr_dir} 
		cp /export/pipeline/RNASeq/Pipeline/noRef_Isoseq/bin/misa.ini ./
		if [ ! -f 'Unigene.fasta' ];then
			ln -s ~{unigene_fasta} Unigene.fasta
		fi
		/export/personal/pengh/Software/misa/misa.pl Unigene.fasta
		perl ~{scriptDir}/p3_in.pl Unigene.fasta.misa
		/export/personal/pengh/Software/primer3-2.3.7/src/primer3_core -default_version=1 < Unigene.fasta.p3in > Unigene.fasta.p3out
		perl ~{scriptDir}/p3_out.pl Unigene.fasta.p3out  Unigene.fasta.misa > Unigene.fa.p3out.log
		sed -i 's#ID#unigene_id#g' Unigene.fasta.results
		sed -i 's#SSR type#SSR_type#g' Unigene.fasta.results
		cut -f 1,3-52 Unigene.fasta.results > SSR.Primer.xls
		cut -f 1-6 SSR.Primer.xls > SSR_results.xls
		Rscript ~{scriptDir}/SSR.r
		touch SSR_done
		date
		" > run_ssr.sh
		bash run_ssr.sh > run_ssr_STDOUT 2> run_ssr_STDERR
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