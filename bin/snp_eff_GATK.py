#!/usr/bin/python

import os,sys, getopt, shutil
import timeit
import readline, glob
from Bio import SeqIO

def main(argv):
	global lib, ref, gtf
	lib = ''
	ref = ''
	gtf = ''
	#~
	try:
		opts, args = getopt.getopt(argv,"l:r:g:")
	except getopt.GetoptError:
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("-l"):
			lib = arg
		elif opt in ("-r"):
			ref = arg
		elif opt in ("-g"):
			gtf = arg
	return lib
if __name__ == "__main__":
	main(sys.argv[1:])

def snp_eff_GATK(lib,ref):
	print 'Pwd ::: ' + os.getcwd()
	a = lib.split('.')[0] + "_in_" + ref.split('.')[0]+"_GATK"
	vcf_name = lib +"_GATK.vcf"
	path = os.getcwd() + "/"+ a +'/' + vcf_name
	h = lib.split('.')[0] +"_GATK.html"
	#Malu: 24/10
	out = os.getcwd() + "/"+ a +'/'+ lib +'_GATK_annotated_SNPs.vcf'
	#log = lib+'_'+ref+'.log'
	nd = lib+'.nodup.bam'
	out_snp = os.getcwd() + "/"+ a +'/'+ lib +'_samtools_annotated_SNPs.vcf'

	#Malu: 23/10
	out_indel = os.getcwd() + "/"+ a +'/'+ lib +'_samtools_annotated_INDEL.vcf'

	os.system("java -jar -Xmx2g snpEff.jar eff  %s %s -ins -no-downstream \
	-no-upstream -s %s> %s " % (a, path, h ,out_indel))
	os.system("java -jar -Xmx2g snpEff.jar eff  %s %s -snp -no-downstream \
	-no-upstream -s %s> %s " % (a, path, h ,out_snp))
	
	#shutil.move(h,a)
	#shutil.move(log,a)
	shutil.move(nd,a)

def copy(f_in, f_out):
	fIn = open(f_in, 'r')  # use raw strings for windows file names
	fOut = open(f_out, "w")
	for line in fIn:
		fOut.write(line)
	fIn.close()
	fOut.close()

snp_eff_GATK(lib,ref)
