#!/usr/bin/python

import os,sys, getopt, shutil
import timeit
import readline, glob
from Bio import SeqIO

def main(argv):
	global lib, ref, gtf, spec
	lib = ''
	ref = ''
	gtf = ''
	spec = ''
	#~
	try:
		opts, args = getopt.getopt(argv,"l:r:g:s:")
	except getopt.GetoptError:
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("-l"):
			lib = arg
		elif opt in ("-r"):
			ref = arg
		elif opt in ("-g"):
			gtf = arg
		elif opt in ("-s"):
			spec = arg
	return lib
if __name__ == "__main__":
	main(sys.argv[1:])

def snp_eff_index_GATK(ref,lib,gtf):
	#creating directories
	
	a = lib.split('.')[0] + "_in_" + ref.split('.')[0]+"_GATK"
	try:
		os.mkdir(a)
	except OSError:
		pass
	#change the reference, gtf and vcf
	copy(ref, "sequences.fa")
	copy(gtf, 'genes.gtf')
	
	vcf_name = lib+"_GATK.vcf"
	
	#move renamed files
	shutil.copy('sequences.fa',a)
	shutil.copy('genes.gtf',a)
	shutil.copy(vcf_name,a)
	
	with open('snpEff.config', 'a') as file:
		global spec
		#ST38.genome : saureus38
		x = a+'.genome: '+ spec+'\n\n'
		file.write(x)
	
	#ST20130939_concat_in_ST20130938_GATK.genome
	return os.system("java -jar snpEff.jar build -gtf22 %s" % a)

def copy(f_in, f_out):
	fIn = open(f_in, 'r')  # use raw strings for windows file names
	fOut = open(f_out, "w")
	for line in fIn:
		fOut.write(line)
	fIn.close()
	fOut.close()

snp_eff_index_GATK(ref,lib,gtf)
