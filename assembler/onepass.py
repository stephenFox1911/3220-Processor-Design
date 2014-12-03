#!/usr/bin/env python
import sys, string

programCounter = 0;

imm=[
"ADDI",
"SUBI",
"ANDI",
"ORI",
"XORI",
"NANDI",
"NORI",
"NXORI",
"MVHI",
"FI",
"EQI",
"LTI",
"LTEI",
"TI",
"NEI",
"GTEI",
"GTI"
]

pcrel=[
"BF",
"BEQ",
"BLT",
"BLTE",
"BEQZ",
"BLTZ",
"BLTEZ",
"BT",
"BNE",
"BGTE",
"BGT",
"BNEZ",
"BGTEZ",
"BGTZ"]

sub=[
"RET",
"BR",
"SUBI",
"NOT",
"CALL",
"JMP",
"RETI"]

alt=[
"SW",
"LW",
"JAL"]

secondArg=[
"MVHI", 
"BEQZ",
"BLTZ",
"BLTEZ", 
"BNEZ",
"BGTEZ",
"BGTZ"]

endingZeroes=[
"ADD",
"SUB",
"AND",
"OR",
"XOR",
"NAND",
"NXOR",
"NOR",
"F",
"EQ",
"LT",
"LTE",
"T",
"NE",
"GTE",
"GT",
"RSR",
"WSR"]
#array of locations that have an empty label
empty={}
#name and value in hex
lookup={
	"R0":'0',
	"R1":'1',
	"R2":'2',
	"R3":'3',
	"R4":'4',
	"R5":'5',
	"R6":'6',
	"R7":'7',
	"R8":'8',
	"R9":'9',
	"R10":'A',
	"SSP":'A',
	"R11":'B',
	"R12":'C',
	"R13":'D',
	"R14":'E',
	"R15":'F',
	"A0":'0',
	"A1":'1',
	"A2":'2',
	"A3":'3',
	"RV":'3',
	"T0":'4',
	"T1":'5',
	"S0":'6',
	"S1":'7',
	"S2":'8',
	"GP":'C',
	"FP":'D',
	"SP":'E',
	"RA":'F',
	"PCS":'00',
	"IHA":'10',
	"IRA":'20',
	"IDN":'30',
	"ADD":'00',
	"SUB":'01',
	"AND":'04',
	"OR":'05',
	"XOR":'06',
	"NAND":'0C',
	"NOR":'0D',
	"NXOR":'0E',
	"ADDI":'80',
	"SUBI":'81',
	"ANDI":'84',
	"ORI":'85',
	"XORI":'86',
	"NANDI":'8C',
	"NORI":'8D',
	"NXORI":'8E',
	"MVHI":'8B',
	"LW":'90',
	"SW":'50',
	"F":'20',
	"EQ":'21',
	"LT":'22',
	"LTE":'23',
	"T":'28',
	"NE":'29',
	"GTE":'2A',
	"GT":'2B',
	"FI":'A0',
	"EQI":'A1',
	"LTI":'A2',
	"LTEI":'A3',
	"TI":'A8',
	"NEI":'A9',
	"GTEI":'AA',
	"GTI":'AB',
	"BF":'60',
	"BEQ":'61',
	"BLT":'62',
	"BLTE":'63',
	"BEQZ":'65',
	"BLTZ":'66',
	"BLTEZ":'67',
	"BT":'68',
	"BNE":'69',
	"BGTE":'6A',
	"BGT":'6B',
	"BNEZ":'6D',
	"BGTEZ":'6E',
	"BGTZ":'6E',
	"JAL":'B0',
	"RSR":'F2',
	"WSR":'F3',
}


#Immediates for the PCRel and ShImm (JAL) should be compiled with 
#word-addresses and all the other immediates should be compiled with byte-addresses. 

def fillLabels(inp, out):
	for line in inp :
		if "LABELREL" in line :
			s=line.split(":")
			lineNumber=int(s[0], 16)
			label=empty[lineNumber]
			labelLoc=lookup[label]
			difference=labelLoc-(lineNumber+1)
			difference=tohex(difference,16)
			difference=difference[2:].upper()
			while len(difference) < 4:
				difference='0'+difference
			line=line.replace("LABELREL", difference)
			out.write(line)
		elif "LABELIMM" in line :
			s=line.split(":")
			lineNumber=int(s[0], 16)
			label=empty[lineNumber]
			labelLoc=lookup[label]
			labelLoc=tohex(labelLoc,16)
			labelLoc=labelLoc[2:].upper()
			while len(labelLoc) < 4:
				labelLoc='0'+labelLoc
			line=line.replace("LABELIMM", labelLoc)
			out.write(line)
		else:
			out.write(line)

def substitute(instruction, out):
	instr=''

	if instruction[0].upper() == "NOT":
		instr="0C"
		args=instruction[1].split(",")
		instr=instr+lookup[args[0].upper()]+lookup[args[1].upper()]+lookup[args[1].upper()]+'000'
		
	elif instruction[0].upper() == "BR" :
		instr="61"
		args=instruction[1]
		instr=instr+'66'+args

	elif instruction[0].upper() == "SUBI" :
		instr="80"
		args=instruction[1].split(",")
		val=int(args[2], 16)
		val=val*(-1)
		val=tohex(val, 16)
		instr=instr+lookup[args[0].upper()]+lookup[args[1].upper()]+val[2:].upper()

	elif instruction[0].upper() == "RET" :
		instr='B09F0000'

	elif instruction[0].upper() == "RETI" :
		instr='F1000000'

	elif instruction[0].upper() == "CALL" :
		instr='B0F'
		s=instruction[1].split("(")
		p=s[1].split(")")
		instr=instr+lookup[p[0].upper()]
		if s[0][1].upper() == 'X' :
			hex=s[0][2:]
			while len(hex) < 4 :
				hex='0'+hex
			instr=instr+hex
		elif s[0][0].isdigit() : 
			hex=tohex(s[0], 16)
			instr=instr+hex.upper()
		else :		#is label
			instr=instr+"LABELIMM"
			l=s[0].upper()+':'
			empty[programCounter]=l

	out.write(instr+';')

#Some instruction have alternate syntax
def assembleAlternate(instruction, out):
	decoded=[]

	instrName=instruction[0]
	if instrName.upper() in lookup :
		decoded.append(lookup[instrName.upper()])
	else :
		decoded.append("**")

	symbol=''
	if instrName.upper() == "SW" :
		s=instruction[1].split('(')
		p=s[1][:-1]
		decoded.append(lookup[p.upper()])
		l=s[0].split(',')
		decoded.append(lookup[l[0].upper()])
		symbol=l[1].upper()
	else :
		s=instruction[1].split(',')
		decoded.append(lookup[s[0].upper()])
		p=s[1].split('(')
		decoded.append(lookup[p[1][:-1].upper()])
		symbol=p[0].upper()

	if symbol.isdigit() or symbol[0] == '-':
		dec=tohex(int(symbol), 16)
		dec=dec[2:]
		while len(dec) < 4 :
			dec='0'+dec
		decoded.append(dec.upper())
	elif ('.'+symbol) in lookup :		#is declaration
		val=lookup[('.'+symbol)]
		if val[1].upper() == "X" :
			decoded.append(val[-4:])
		else :
			dec=hex(int(val, 10))
			dec=dec[2:]
			while len(dec) < 4 :
				dec='0'+dec
			decoded.append(dec)
	else : 	#is label
		if (symbol+':') in lookup :
			val=lookup[(symbol+':')]
			dec=hex(int(val, 10))
			dec=dec[2:]
			while len(dec) < 4 :
				dec='0'+dec
			decoded.append(dec)
		else :
			decoded.append("LABELIMM")
			empty[programCounter]=(symbol+':')

	decoded=clean(decoded)
	out.write(str(decoded)+';')

def readInstruction(instruction, out):
	decoded=[]
	temp=instruction[0]
	
	if temp.upper() in lookup :	#replace instruction with decoded value
		decoded.append(lookup[temp.upper()])
	else :
		decoded.append("**")

	if temp.upper() in alt :
		assembleAlternate(instruction, out)
		return
	
	instrName=temp
	if instrName.upper() in sub : 
		substitute(instruction, out)
		return

	args=instruction[1].split(",")
	i=0
	for arg in args:	#replace all arguments with decoded values
		if instrName.upper() in secondArg :
			if i is 1 :
				decoded.append("0")
		temp=args[i].upper()

		if temp in lookup :	#replace argument with decoded value
			decoded.append(lookup[temp])
		elif temp[0] is '-' : #negative number
			x=int(temp)
			y=tohex(x,16)
			decoded.append(y[2:].upper())
			
		elif temp[0].isdigit() :
			if len(temp) is 1 :		# single digit number
				decoded.append('000' + temp[0])
			else :
				if "0x" in temp or "0X" in temp:		#hexidecimal number
					hexi=''
					j=0
					while j < (len(temp)-2) :
						hexi=hexi+temp[2+j]
						j=j+1
					while j < 4 :
						hexi='0'+hexi
						j=j+1
					decoded.append(hexi)
				else : 	#multiple digit positive decimal
					dec=hex(int(temp, 10))
					dec=dec[2:]
					while len(dec) < 4 :
						dec='0'+dec
					decoded.append(dec)
		
		else :	#argument not found this is a label
			check='.'+temp
			if check in lookup :
				val=lookup[check]
				if val[1].upper() == "X" :
					val=val[2:6]
					while len(val) < 4 :
						val='0'+val
					decoded.append(val)
				else :
					dec=hex(int(val, 10))
					dec=dec[2:]
					while len(dec) < 4 :
						dec='0'+dec
					decoded.append(dec)
			else :
				lbl=temp+':'
				empty[programCounter]=lbl
				if instrName.upper() in imm :				
					decoded.append("LABELIMM")
				elif instrName.upper() in pcrel :
					decoded.append("LABELREL")
		i=i+1

	if instrName.upper() in endingZeroes :
		decoded.append("000")
	decoded=clean(decoded)
	out.write(str(decoded) + ';')

def read(program, out):
	global programCounter
	
	out.write("WIDTH=32;\nDEPTH=2048;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n")
	
	for line in program :
		temp = string.split(line)

		if not temp : continue	#empty line

		if temp[0][0]==';' : continue	#comment line, ignore
		if temp[0][0]=='.' : #Declaration line, save
			if temp[0][1] is 'O' :	#Origin declartion
				lookup['Origin']=temp[1]
				programCounter=int(lookup['Origin'], 16)	#update program counter
			elif temp[0][1] is 'N' :	#Name declaration
				#checks for different input styles to allow small typos
				if len(temp) is 2 : #Input: .NAME ABDC=0x1234
					s=temp[1].split("=")
					name='.'+s[0]
					lookup[name.upper()]=s[1]
				else : #Input: .NAME ABDC= 0x1234 or ABCD =0x1234
					s=temp[1].split("=")
					name='.'+s[0]
					s=temp[2].split("=")
					if not s[0] :
						val=s[1]
					else :
						val=s[0]
					lookup[name.upper()]=val
		elif line[0] > ' ' : #Line starts with a letter, is a label
			s=temp[0].split(';')
			lbl=s[0]
			lookup[s[0].upper()]=programCounter
			if len(temp) > 1 :	#If an instruction follows the label
				if temp[1][0] == ';' :
					pass
				elif temp[0][-1] == ';' :
					pass
				else :
					instr=[0 for x in range(0,len(temp)-1)]
					for i in xrange(0,len(temp)-1):
						instr[i]=temp[i+1]	
					printPC(out)
					readInstruction(instr, out)
					out.write("\n")
					programCounter=programCounter+1
		else : #line is an instruction, 
			printPC(out)
			readInstruction(temp, out)
			out.write("\n")
			programCounter=programCounter+1
	h=tohex(programCounter, 16)
	h=h[2:].upper()
	while len(h) < 4 :
		h='0'+h
	out.write('['+h+'..07FF] : DEAD;\nEND;')
	program.seek(0)

def twos_comp(val, bits):
	if( (val&(1<<(bits-1))) != 0 ):
		val = val - (1<<bits)
	return val

def clean(var):
	ret=''
	for p in var:
		ret=ret+p 
	return ret

def printPC(out):
	ret=hex(programCounter)
	ret=ret[2:]
	while len(ret) < 8 :
		ret='0'+ret
	out.write(ret + " : ")

def tohex(val, nbits):
  return hex((val + (1 << nbits)) % (1 << nbits))

def main():
	sourceFile = raw_input("Enter source file (.a32): ")
	destinationFile = raw_input("Enter destination file (.mif): ")

	program = open(sourceFile, "r")
	out=open("middle.mid", "w")

	read(program, out)
	out.close()
	program.close()

	inp=open("middle.mid", "r")
	out=open(destinationFile, "w")
	fillLabels(inp, out)

if __name__ == "__main__" : main()