

import sys, argparse, re, pickle
from math import log2
from enum import Enum
from collections import OrderedDict

comment_pattern = r'(?:\s*;.*)?$'
line_pattern = r'(\w+)(?:\s+((?:(?:[\w+-]+|\([\w+-]+\))(?:,\s*)?)+))?%s' % comment_pattern
re_directive = re.compile(r'\.(\w+)\s+((\w+)\s*=\s*([^\W_]+)|(\w+))%s' % comment_pattern)
re_label = re.compile(r'(\w+)\s*:\s*(%s)?%s' % (line_pattern, comment_pattern))
re_line = re.compile(line_pattern)
re_fmt = re.compile(r'"\s*(\w+)\s*((?:[\w()+-]+(?:\s*,\s*)?)*)\s*"')
re_word = re.compile(r'[\w()+-]+')
re_reg = re.compile(r'[\w+-]+')

registers = {'A0': 0, 'A1': 1, 'A2': 2, 'A3': 3, 'RV': 3, 'T0': 4, 'T1': 5, 'S0': 6, 'S1': 7, 'S2': 8, 'GP': 12, 'FP': 13, 'SP': 14, 'RA': 15,
			 'R0': 0, 'R1': 1, 'R2': 2, 'R3': 3, 'R4': 4, 'R5': 5, 'R6': 6, 'R7': 7, 'R8': 8, 'R9': 9, 'R10': 10, 'R11': 11, 'R12': 12, 'R13': 13, 'R14': 14, 'R15': 15}

class Format(Enum):
	empty = 0
	rd = 1
	rs1 = 2
	rs2 = 3
	imm = 4
	immr = 5
	immhi = 6
	shimm = 7
	op1 = 8
	op2 = 9
	rel = 10
	reg = 11
	number = 12

class Directive(Enum):
	orig = "ORIG"
	name = "NAME"
	word = "WORD"

class LineChecker:

	def __init__(self):
		self.match = None

	def checkLine(self, pattern, l):
		self.match = pattern.match(l)
		return self.match is not None

	def group(self, n):
		return self.match.group(n)

class ISA:

	isa = {}

	# initialize a new ISA from a text file containing the ISA
	def __init__(self, filename, options=None):
		self.filename = filename
		if options:
			self.opt = options
			self.parseIsa()
		else: self.load()

	def parseIsa(self):
		with open(self.filename) as f:
			content = f.readlines()

		fmt_pattern = r'%s\s*:\s*"\s*((?:[\w()]+(?:\s*,\s*)?)*)\s*"' % self.opt.fmt
		iword_pattern = r'%s\s*:\s*"([\w\s]*)"' % self.opt.iword
		itext_pattern = r'%s\s*:\s*\[(["\w\s(),+-]+)\]' % self.opt.itext
		re_instr = re.compile(r'(\w+)\s*:\s*\{\s*%s\s*,\s*(?:(?:%s)|(?:%s))\}$' % (fmt_pattern, iword_pattern, itext_pattern))

		re_reg_custom = re.compile(r'%s(\d+)' % self.opt.reg)
		re_imm_custom = re.compile(r'(%s|(?:0x)?\d+)\(([\w\d]+)\)' % self.opt.imm)
		re_immr_custom = re.compile(r'%s\(([\w\d]+)\)' % self.opt.imm)
		lc = LineChecker()
		toFormat = { self.opt.rd: Format.rd, self.opt.rs: Format.rs1, self.opt.rs1: Format.rs1,
				self.opt.rs2: Format.rs2, self.opt.reg: Format.reg, self.opt.imm: Format.imm,
				self.opt.rel: Format.rel, self.opt.shimm: Format.shimm, self.opt.immhi: Format.immhi }
		lineNumber = 0

		for line in content:
			lineNumber += 1
			l = line.strip().upper()
			if not l or l.startswith('//'): continue
			if lc.checkLine(re_instr, l): op = lc.group(1)
			else: throwError("Invalid line: '%s' in line number %d" % (l, lineNumber), 5)
			fmt = [x.strip() for x in lc.group(2).split(",")]
			instr = lc.group(3) if lc.group(3) else lc.group(4)
			opSet = []
			for idx, f in enumerate(fmt):
				if not f: break
				elif f in (self.opt.rd, self.opt.rs, self.opt.rs1, self.opt.rs2, self.opt.imm, self.opt.rel):
					opSet.append(toFormat[f])
				elif f.startswith(self.opt.imm):
					r = re_immr_custom.match(f)
					if not r:
						throwError("Invalid format specifier: '%s' in line number %d" % (f, lineNumber), 5)
					opSet.append(Format.immr)
					r = r.group(1)
					opSet.append(toFormat[r])
				else:
					throwError("Invalid format specifier: '%s' in line number %d" % (f, lineNumber), 5)
			self.isa[op] = [opSet]
			instrSet = []
			if lc.group(3):
				i = lc.group(3).strip().split()
				opAppended = False
				for idx, t in enumerate(i):
					if t in (self.opt.rd, self.opt.rs, self.opt.rs1, self.opt.rs2):
						instrSet.append((toFormat[t], self.opt.reg_width))
					elif t in (self.opt.imm, self.opt.immhi, self.opt.shimm, self.opt.rel):
						instrSet.append((toFormat[t], self.opt.imm_width))
					else:
						try: v = int(t, 2)
						except ValueError:
							throwError("Invalid value in IWORD: '%s' in line number %d" % (t, lineNumber), 5)
						if idx == self.opt.op1:
							instrSet.append((Format.op1, self.opt.op1_width, v))
						elif idx == self.opt.op2:
							instrSet.append((Format.op2, self.opt.op2_width, v))
						else:
							instrSet.append((Format.number, len(t), v))
				count_chk = 0
				for instrSet_chk in instrSet:
					count_chk += instrSet_chk[1]
				if count_chk != self.opt.width:
					throwError("The number of bits in the IWORD (%d) does not "
							   "match the width (%d) for instruction: '%s' in line number %d" % (count_chk, self.opt.width, op, lineNumber), 5)
				self.isa[op].append(instrSet)
			else:
				i = lc.group(4)
				text = re_fmt.findall(i)
				if not text:
					throwError("Invalid ITEXT: '%s' found in line number %d" % (i, lineNumber), 5)
				for fmt in text:
					_fmt = re_word.findall(fmt[1])
					t = []
					if fmt[0] not in self.isa:
						throwError("Unknown instruction used in ITEXT: '%s' in line number %d" % (fmt[0], lineNumber), 5)
					tOrig = self.isa[fmt[0]]
					for reg in _fmt:
						if reg in (self.opt.rd, self.opt.rs, self.opt.rs1, self.opt.rs2):
							t.append((toFormat[reg], self.opt.reg_width))
						elif reg in (self.opt.imm, self.opt.rel):
							t.append((toFormat[reg], self.opt.imm_width))
						elif lc.checkLine(re_imm_custom, reg):
							if lc.group(1) == self.opt.imm:
								t.append((Format.immr, self.opt.imm_width))
							else:
								t.append((Format.immr, self.opt.imm_width, int(lc.group(1), 0)))
							t.append(self.checkRegister(lc.group(2), toFormat))
						elif reg in registers:
							t.append((Format.reg, self.opt.reg_width, registers[reg]))
						elif lc.checkLine(re_reg_custom, reg):
							t.append((Format.reg, self.opt.reg_width, int(lc.group(1))))
						else:
							try:
								value = int(reg, 0)
								t.append((Format.imm, self.opt.imm_width, value))
							except ValueError:
								throwError("Invalid format specifier: '%s' in line number %d" % (reg, lineNumber), 5)
					tNew = []
					for form in tOrig[1]:
						if form[0] in (Format.op1, Format.op2, Format.number):
							tNew.append(form)
						elif form[0] in (Format.imm, Format.rel, Format.shimm):
							idx = tOrig[0].index(Format.imm) if Format.imm in tOrig[0] else tOrig[0].index(Format.immr)
							tt = list(t[idx])
							tt[0:2] = list(form)
							tNew.append(tuple(tt))
						else:
							tNew.append(t[tOrig[0].index(form[0])])
					self.isa[op].append(tNew)

		if self.opt.verbose:
			print("ISA: %s\n" % self.isa)

	def load(self):
		with open(self.opt.isa, 'rb') as f:
			self.isa = pickle.load(f)

	def save(self):
		with open(self.opt.save, 'wb') as f:
			pickle.dump(self.isa, f)

	def checkRegister(self, reg, toFormat):
		if reg in (self.opt.rd, self.opt.rs, self.opt.rs1, self.opt.rs2):
			return (toFormat[reg], self.opt.reg_width)
		elif reg in registers:
			return (Format.reg, self.opt.reg_width, registers[reg])
		else:
			r = re.compile(r'%s(\d+)' % self.opt.reg).match(reg)
			if r: return (Format.reg, self.opt.reg_width, int(lc.group(1)))
		throwError("Invalid format specifier: '%s'" % reg, 5)

def upper(arg):
	return arg.upper()

def main():
	parser = argparse.ArgumentParser(description="This is a compiler for both a customized ISA and an assembly code.")
	parser.add_argument("-v", "--verbose", action="store_true", default=False, help="print out the progress wherever applicable")
	parser.add_argument("-q", "--quiet", action="store_true", default=False, help="silence the warnings")
	parser.add_argument("-f", "--filename", metavar="FILE", help="file name for the assembly code to compile")
	parser.add_argument("-o", "--output", metavar="FILE", help="file name for the compiled code (.mif) [default: 'filename'.mif]")
	parser.add_argument("-i", "--isa", default="isa.txt", metavar="FILE", help="file containing the custom ISA\n"
														"(If the file extension is .isa, it will load the pre-compiled binary ISA file. "
														"Otherwise, it will parse the given text file) [default: isa.txt]")
	parser.add_argument("-s", "--save", nargs="?", const="isa.isa", default=None, metavar="FILE", help="save the compiled ISA file as a binary file [default: isa.isa]")
	parser.add_argument("-d", "--depth", type=int, default=2048, help="set depth (size of the memory) for the compiled assembly code [default: 2048]")
	parser.add_argument("-w", "--width", type=int, default=32, help="set width (bit width for each instruction) for the compiled assembly code [default: 32]")
	parser.add_argument("--addrRadix", type=int, default=16, metavar="RADIX", help="radix used for addresses in the compiled assembly code (16, 2, 10, or 8) [default: 16]")
	parser.add_argument("--dataRadix", type=int, default=16, metavar="RADIX", help="radix used for instructions (data) in the compiled assembly code (16, 2, 10, or 8) [default: 16]")
	parser.add_argument("--reg-width", type=int, default=4, metavar="WIDTH", help="bit width for the regsiters [default: 4]")
	parser.add_argument("--imm-width", type=int, default=16, metavar="WIDTH", help="bit width for the immediates [default: 16]")
	parser.add_argument("--op1-width", type=int, default=4, metavar="WIDTH", help="bit width for the first opcode [default: 4]")
	parser.add_argument("--op2-width", type=int, default=4, metavar="WIDTH", help="bit width for the second opcode [default: 4]")
	parser.add_argument("--rd", type=upper, default="RD", metavar="WORD",
							    help="word and bit width for the destination register in the ISA [default: RD]")
	parser.add_argument("--rs", type=upper, default="RS", metavar="WORD",
							    help="word and bit width for the source register in the ISA [default: RS]")
	parser.add_argument("--rs1", type=upper, default="RS1", metavar="WORD",
							    help="word and bit width for the source register 1 in the ISA [default: RS1]")
	parser.add_argument("--rs2", type=upper, default="RS2", metavar="WORD",
							    help="word and bit width for the source register 2 in the ISA [default: RS2]")
	parser.add_argument("--reg", type=upper, default="R", metavar="WORD",
							    help="word and bit width for the numbered registers in the ISA [default: R]")
	parser.add_argument("--imm", type=upper, default="IMM", metavar="WORD",
							    help="word and bit width for the immediate in the ISA [default: Imm]")
	parser.add_argument("--rel", type=upper, default="PCREL", metavar="WORD",
							    help="word and bit width for the PC relative in the ISA [default: PCRel]")
	parser.add_argument("--shimm", type=upper, default="SHIMM", metavar="WORD",
							    help="word and bit width for the shifted immediate in the ISA [default: ShImm]")
	parser.add_argument("--immhi", type=upper, default="IMMHI", metavar="WORD",
							    help="word and bit width for the immediate high in the ISA [default: ImmHi]")
	parser.add_argument("--op1", type=int, default=0, metavar="POSITION",
							    help="position and bit width for the first part of an opcode in the ISA [default: 0]")
	parser.add_argument("--op2", type=int, default=1, metavar="POSITION",
							    help="position and bit width for the second part of an opcode in the ISA [default: 1]")
	parser.add_argument("--iword", type=upper, default="IWORD", metavar="WORD", help="word for IWORD (binary instruction) in the ISA [default: IWORD]")
	parser.add_argument("--itext", type=upper, default="ITEXT", metavar="WORD", help="word for ITEXT (instruction defined using other instructions) in the ISA [default: ITEXT]")
	parser.add_argument("--fmt", type=upper, default="FMT", metavar="WORD", help="word for FMT (format for an instruction) in the ISA [default: FMT]")
	args = parser.parse_args()

	radixDict = {16: (16, "HEX", "x"), 10: (10, "DEC", "d"), 2: (2, "BIN", "b"), 8: (8, "OCT", "o")}
	try:
		args.addrRadix = radixDict[args.addrRadix]
		args.dataRadix = radixDict[args.dataRadix]
	except KeyError as e:
		throwError("Invalid radix given: %s -- it has to be 16, 2, 10, or 8" % e, 2)
	if not args.quiet and log2(args.width) % 1:
		print("WARNING: The given width %d is not a power of 2; this may cause some problems" % args.width)
	args.widthAddrDiv = round(args.width/log2(args.addrRadix[0]))
	args.widthDataDiv = round(args.width/log2(args.dataRadix[0]))
	args.widthAddr = args.widthAddrDiv + (2 if args.addrRadix[0] != 10 else 0)
	if args.filename and not args.output:
		name = args.filename.split('.')[:-1]
		args.output = '%s.mif' % ('.'.join(name) if name else args.filename)
	elif not args.filename and not args.save:
		throwError("No filename for an assembly code to compile given\n"
				   "To just compile and save an ISA, pass -s/--save as an argument", 2)

	isaext = args.isa.split('.')[-1]
	if isaext == 'isa': isa = ISA(args.isa)
	elif isaext == 'txt': isa = ISA(args.isa, args)
	else: throwError("ISA with an invalid extension (%s) given (has to be either .txt or .isa)", 2)

	if args.save: isa.save()
	if not args.filename: sys.exit(0)

	with open(args.filename) as f:
		content = f.readlines()

	address = 0
	labels = {}
	instructions = {}
	words = {}
	lineNumber = 0
	lc = LineChecker()

	for line in content:
		lineNumber += 1
		l = line.strip().upper()
		if not l or l[0] == ';':
			# empty or a comment
			continue	# ignore
		elif lc.checkLine(re_directive, l):
			# special directive
			directive = lc.group(1)
			if directive == Directive.orig.value:
				try:
					address = int(lc.group(2), 0) >> 2
				except ValueError:
					throwError("Unknown value found for ORIG directive: '%s' in line number: %d" % (lc.group(2), lineNumber), 3)
			elif directive == Directive.name.value:
				name = lc.group(3)
				try:
					value = int(lc.group(4), 0)
				except ValueError:
					throwError("Unknown value found for NAME directive: '%s' in line number: %d" % (lc.group(4), lineNumber), 3)
				if name in labels:
					throwError("Multiple definition of a same label: '%s' found in line number: %d" % (name, lineNumber), 3)
				labels[name] = value
			elif directive == Directive.word.value:
				word = lc.group(2)
				try: word = int(word, 0)
				except ValueError: pass
				if address in instructions and not args.quiet:
					print("WARNING: a WORD placed at the same address as another instruction at: 0x%x (0x%x)"
						  "\n=> Overwriting previous instruction" % (address, address << 2))
				instructions[address] = (Directive.word, word)
				address += 1
			else:
				throwError("Invalid directive: '%s' in line number: %d" % (directive, lineNumber), 3)
		elif lc.checkLine(re_label, l):
			# label
			label = lc.group(1)
			labels[label] = address << 2
			if lc.group(3):
				op = lc.group(3)
				if op not in isa.isa:
					throwError("Unknown instruction: '%s' used in line number: %d" % (op, lineNumber), 3)
				regs = [x.strip() for x in re_reg.findall(lc.group(4))] if lc.group(4) else []
				if len(regs) != len(isa.isa[op][0]):
					throwError("The number of arguments given (%d) does not match the required format (%d) for instruction:\n" \
							   "'%s' in line: '%s' in line number: %d" % (len(regs), len(isa.isa[op][0]), op, l, lineNumber), 3)
				if address in instructions and not args.quiet:
					print("WARNING: multiple instructions found at the same address: 0x%x (0x%x)"
						  "\n=> Overwriting previous instruction" % (address, address << 2))
				instructions[address] = (op, regs)
				address += len(isa.isa[op]) - 1	# Increment the address
		elif lc.checkLine(re_line, l):
			# regular line
			op = lc.group(1)
			if op not in isa.isa:
				throwError("Unknown instruction: '%s' used in line number: %d" % (op, lineNumber), 3)
			regs = [x.strip() for x in re_reg.findall(lc.group(2))] if lc.group(2) else []
			if len(regs) != len(isa.isa[op][0]):
				throwError("The number of arguments given (%d) does not match the required format (%d) for instruction:\n" \
						   "'%s' in line: '%s' in line number: %d" % (len(regs), len(isa.isa[op][0]), op, l, lineNumber), 3)
			if address in instructions and not args.quiet:
				print("WARNING: multiple instructions found at the same address: 0x%x (0x%x)"
					  "\n=> Overwriting previous instruction" % (address, address << 2))
			instructions[address] = (op, regs)
			address += len(isa.isa[op]) - 1	# Increment the address
		else:
			throwError("Invalid line: '%s' in line number: %d" % (l, lineNumber), 3)

	output = open(args.output, 'w')
	output.write('WIDTH=%d;\nDEPTH=%d;\nADDRESS_RADIX=%s;\nDATA_RADIX=%s;\nCONTENT BEGIN\n' % (args.width, args.depth, args.addrRadix[1], args.dataRadix[1]))

	if args.verbose: print("LABELS: %s\n" % labels)

	instructions = OrderedDict(sorted(instructions.items(), key=lambda t: t[0]))

	prevAddress = -1

	for addr, instr in instructions.items():
		if addr != (prevAddress + 1):
			if addr - prevAddress == 2:
				output.write("%0*x : DEAD;\n" % (args.widthAddrDiv, prevAddress + 1))
			else:
				output.write("[%0*x..%0*x] : DEAD;\n" % (args.widthAddrDiv, prevAddress + 1, args.widthAddrDiv, addr - 1))
		op = instr[0]
		if op == Directive.word:
			result = instr[1] if type(instr[1]) is int else labels[instr[1]]
			resultStr = ("{0:#0{1}x}".format(instr[1], args.widthAddr)) if type(instr[1]) is int else instr[1]
			output.write("-- @ {0:#0{1}{2}} : {3}\n".format(addr << 2, args.widthAddr, args.addrRadix[2], resultStr))
			output.write("{0:0{1}{2}} : {3:0{4}{5}};\n".format(addr, args.widthAddrDiv, args.addrRadix[2], result, args.widthDataDiv, args.dataRadix[2]))
			prevAddress = addr
			addr += 1
			continue
		if op not in isa.isa:
			throwError("Unsupported operation: '%s' at address: 0x%0*x (0x%0*x)" % (op, args.widthAddrDiv, addr, args.widthAddrDiv, addr << 2), 4)
		formatInstr = isa.isa[op]
		for i in formatInstr[1:]:
			output.write("-- @ {0:#0{1}{2}} : {3}\t{4}\n".format(addr << 2, args.widthAddr, args.addrRadix[2], op, convertBack(instr[1], formatInstr[0])))
			result = 0
			for f in i:
				result = (result << f[1]) | (~(-1 << f[1]) & convertValue(f, instr[1], formatInstr[0], addr, labels))
			output.write("{0:0{1}{2}} : {3:0{4}{5}};\n".format(addr, args.widthAddrDiv, args.addrRadix[2], result, args.widthDataDiv, args.dataRadix[2]))
			addr += 1
		prevAddress = addr - 1
	if addr < (args.depth-1):
		output.write("[%0*x..%0*x] : DEAD;\n" % (4, addr, 4, args.depth-1))

	output.write('END;\n')
	output.close()

def convertValue(value, regs, format, addr, labels):
	oper = value[0]
	try:
		if len(value) == 3:
			return value[2]
		elif oper == Format.rel:
			v = regs[format.index(Format.imm)]
			return ((labels[v] >> 2) - (addr + 1)) if v in labels else ((int(v, 0) >> 2) - (addr + 1))
		elif oper == Format.shimm:
			if Format.imm in format:
				v = regs[format.index(Format.imm)]
			else:
				v = regs[format.index(Format.immr)]
			return (labels[v] if v in labels else int(v, 0)) >> 2
		elif oper == Format.imm:
			if Format.imm in format:
				v = regs[format.index(Format.imm)]
			else:
				v = regs[format.index(Format.immr)]
			return labels[v] if v in labels else int(v, 0)
		elif oper == Format.immr:
			v = regs[format.index(Format.immr)]
			return labels[v] if v in labels else int(v, 0)
		elif oper == Format.immhi:
			if Format.imm in format:
				v = regs[format.index(Format.imm)]
			else:
				v = regs[format.index(Format.immr)]
			return (labels[v] if v in labels else int(v, 0)) >> value[1]
		else:
			try:
				return registers[regs[format.index(oper)]]
			except KeyError:
				throwError("A register required, but an unknown register: '%s' "
						   "found at address: 0x%x (0x%x)" % (regs[format.index(oper)], addr, addr << 2), 6)
	except ValueError:
		throwError("Invalid value found: '%s' at address: 0x%x (0x%x)" % (v, addr, addr << 2), 6)

def convertBack(regs, format):
	result = ""
	skip = False
	for idx, f in enumerate(format):
		if skip:
			skip = False
			continue
		result += "," if result else ""
		if f == Format.immr:
			result += "%s(%s)" % (regs[idx], regs[idx+1])
			skip = True
		else:
			result += regs[idx]
	return result

def throwError(err, errno):
	print("\n\033[91m\033[1m--- ERROR ---\033[0m\n" \
		  "\033[1m%s\033[0m\n" % err);
	sys.exit(errno)

if __name__ == "__main__":
	main()
