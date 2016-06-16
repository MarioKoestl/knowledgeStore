# python wordCount_MarioKoestl.py -f/-file [inputfile] -l/-language [ger/eng]
# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import sys,re,argparse
from operator import itemgetter


reload(sys)  
sys.setdefaultencoding('utf-8')


parser = argparse.ArgumentParser(description='output the frequency of all word in given textfile.');
parser.add_argument('-f','--file',required=True,help='file path',metavar='FILE');
parser.add_argument('-l','--language',required=True,help='set language of input text',choices=['eng','ger'],metavar='LANGUAGE');
args=parser.parse_args();

filename,language = args.file,args.language;


content="";
dic = {};
umlaute = { 'Ä':'AE', 'Ö':'OE', 'Ü':'UE', 'ß':'SS' };
if(language=="eng"):
	with open(filename,'r') as fp:
		content=fp.read().replace('\n','');
	content = re.sub(r"[^\w+]", " ", content.strip());
	
if(language=="ger"):
	with open(filename,'r') as fp:
		content=fp.read().decode('utf8').replace('\n','');
	content = re.sub(r"(?u)[^\w]", " ", content.strip());
	for umlaut in umlaute.keys():
                content = re.sub(umlaut,umlaute[umlaut],content.upper())

words = content.split();

for word in words:
	key=word.upper();
	
	if(key in dic):
		dic[key]+=1;
	else:
		dic[key]=1;

sortedList = sorted(dic.iteritems(), key = itemgetter(1), reverse=True);
for k,v in sortedList:
    print k, v;
