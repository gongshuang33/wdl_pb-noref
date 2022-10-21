version 1.0

import "tasks/diff_tasks.wdl" as diff_tasks

workflow RunDGE {
	input {
		String diff_dir
		String? sample_group
		String? compare_txt
		String gene_count
		String gene_fpkm
		String gene_tpm
		String scriptDir
		# Map[String, String] dockerImages		 
	}
		
	if(defined(compare_txt)) {
		call diff_tasks.write_diff_script {
			input:
				diff_dir = diff_dir,
				sample_group = sample_group,
				compare_txt = compare_txt,
				gene_count = gene_count,
				gene_fpkm = gene_fpkm,
				# gene_tpm = gene_tpm,
				scriptDir = scriptDir,
				# image = dockerImages["diff"]
		}

		call diff_tasks.DGETask {
			input:
				diff_dir = diff_dir,
				diff_script = write_diff_script.diff_script,
				scriptDir = scriptDir,
				# image = dockerImages["diff"]
		}
	}

	output {
		String dge_stat = diff_dir_done + "/DEG_stat.xls"
		String diff_dir_done = DGETask.diff_dir_done
	}
}

task DgeAddAnnotTask {
	input {
		String diff_dir_done
		String go_annotation_xls
		String kegg_annotation_xls
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image

		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex

		cd ~{diff_dir_done}

		if [ -f "diff_annot.done" ]; then
			exit 0
		fi

		for i in `ls | grep "_vs_"`;do
			python3 ~{scriptDir}/combine_diff_annot.py -diff $i/$i.DEG.xls -go ~{go_annotation_xls} -kegg ~{kegg_annotation_xls} -o $i/$i.DEG.Annotation.xls
			python3 ~{scriptDir}/combine_diff_annot.py -diff $i/$i.DEG_up.xls -go ~{go_annotation_xls} -kegg ~{kegg_annotation_xls} -o $i/$i.DEG_up.Annotation.xls
			python3 ~{scriptDir}/combine_diff_annot.py -diff $i/$i.DEG_down.xls -go ~{go_annotation_xls} -kegg ~{kegg_annotation_xls} -o $i/$i.DEG_down.Annotation.xls
		done

		touch diff_annot.done
	>>>

	output {
		String diff_annot_done = diff_dir_done + "/diff_annot.done"
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}