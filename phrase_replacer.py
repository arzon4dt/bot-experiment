import glob
import os

phrase = "item_ring_of_basilius"	
replacer = "item_"
found = 0
path = "E:\\Steam\\SteamApps\\common\\dota 2 beta\\game\\dota\\scripts\\vscripts\\bots\\builds"
for filename in glob.glob(os.path.join(path, '*.lua')):
	phraseFound = False;
	file = open(filename, "r")
	lines = file.readlines()
	file.close()
	for line in lines:
		if str.find(line, phrase) != -1:
			phraseFound = True
			found += 1
			break	
	if phraseFound:
		print(filename.replace(path, ""))
		file = open(filename, "w")
		for line in lines:
			if str.find(line, phrase) != -1:
				file.write(line.replace(phrase, replacer))
			else:			
				file.write(line)
		file.close()		
if found > 0:
	print(str(found)+" file(s) modified.")
else:
	print("Phrase not found in file(s).")
	
