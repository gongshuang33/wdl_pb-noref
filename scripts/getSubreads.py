import os
import sys

subreads_file = sys.argv[1]
work_dir = sys.argv[2]

with open(subreads_file, 'r') as f:
	sample = []
	# os.system("mkdir -p %s/Subreads" % work_dir)
	for line in f.readlines():
		movie = line.strip().split()[0]
		bam = line.strip().split()[1]
		sample.append(movie)
		if not os.path.exists('%s/%s.subreads.bam' % (work_dir, movie)):
			os.system("ln -s %s %s/%s.subreads.bam" % (bam, work_dir, movie))
			os.system("ln -s %s.pbi %s/%s.subreads.bam.pbi" % (bam, work_dir, movie))
