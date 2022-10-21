version 1.0

task join_string_array {
	input {
		Array[String] str_arr
	}

	command {
		echo ${sep='_vs_' str_arr}
	}

	output {
		String joined_string = read_string(stdout())
	}

	runtime {
		# docker: "grandomics-cn-beijing.cr.volces.com/grandomics/centos:7.9.2009"
		cpu: 1
		memory: '1G'
		# disk: '1 G'
	}
}


workflow tsv_to_string {
	input {
		String? tsv_path
	}

	if(defined(tsv_path)) {
		Array[Array[String]] lines = read_tsv(tsv_path)
		scatter (line in lines) {
			call join_string_array {
				input:
					str_arr = line
			}
		}
	}
		

	output {
		Array[String] joined_strings = join_string_array.joined_string
		Array[String] comp_strings = joined_strings
	}
}
		
