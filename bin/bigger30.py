#!/usr/bin/python

import os,sys, getopt, shutil
import timeit
import readline, glob
from Bio import SeqIO

def main(argv):
	global lib
	lib = ''
	#~
	try:
		opts, args = getopt.getopt(argv,"l:")
	except getopt.GetoptError:
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("-l"):
			lib = arg
	return lib
if __name__ == "__main__":
	main(sys.argv[1:])

def bigger_30mer(lib):
	"""get sequences bigger than 30 nt"""
	
	handle = open(lib, 'rU')
	#fl_out = lib.split(".")[0] +'.bigger30.fq'
	fl_out = lib + '.bigger30.fq'  
	print fl_out
	output_handle = open(fl_out, "w")
	
	for seq_record in SeqIO.parse(handle, "fastq"):
		if len(seq_record.seq) >= 30:
			SeqIO.write(seq_record, output_handle, "fastq") 
	handle.close()
	output_handle.close()

print '\nRetrieving reads bigger than 30nt in '+lib+'...'
bigger_30mer(lib)
