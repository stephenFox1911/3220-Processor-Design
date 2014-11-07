#!/usr/bin/env perl

#use Switch;

local $addr=0;
local $lnum=0;
local %mem;
%opmap = (
    ADD   => {FMT=> "RD,RS1,RS2",  IWORD=>"0000 0000 RD   RS1  RS2  000000000000"},
    SUB   => {FMT=> "RD,RS1,RS2",  IWORD=>"0000 0001 RD   RS1  RS2  000000000000"},
    AND   => {FMT=> "RD,RS1,RS2",  IWORD=>"0000 0100 RD   RS1  RS2  000000000000"},
    OR    => {FMT=> "RD,RS1,RS2",  IWORD=>"0000 0101 RD   RS1  RS2  000000000000"},
    XOR   => {FMT=> "RD,RS1,RS2",  IWORD=>"0000 0110 RD   RS1  RS2  000000000000"},
    NAND  => {FMT=> "RD,RS1,RS2",  IWORD=>"0000 1100 RD   RS1  RS2  000000000000"},
    NOR   => {FMT=> "RD,RS1,RS2",  IWORD=>"0000 1101 RD   RS1  RS2  000000000000"},
    NXOR  => {FMT=> "RD,RS1,RS2",  IWORD=>"0000 1110 RD   RS1  RS2  000000000000"},
    ADDI  => {FMT=> "RD,RS1,Imm",  IWORD=>"1000 0000 RD   RS1                 Imm"},
    SUBI  => {FMT=> "RD,RS1,Imm",  IWORD=>"1000 0001 RD   RS1                 Imm"},
    ANDI  => {FMT=> "RD,RS1,Imm",  IWORD=>"1000 0100 RD   RS1                 Imm"},
    ORI   => {FMT=> "RD,RS1,Imm",  IWORD=>"1000 0101 RD   RS1                 Imm"},
    XORI  => {FMT=> "RD,RS1,Imm",  IWORD=>"1000 0110 RD   RS1                 Imm"},
    NANDI => {FMT=> "RD,RS1,Imm",  IWORD=>"1000 1100 RD   RS1                 Imm"},
    NORI  => {FMT=> "RD,RS1,Imm",  IWORD=>"1000 1101 RD   RS1                 Imm"},
    NXORI => {FMT=> "RD,RS1,Imm",  IWORD=>"1000 1110 RD   RS1                 Imm"},
    MVHI  => {FMT=> "RD,Imm",      IWORD=>"1000 1011 RD   0000              ImmHi"},
    LW    => {FMT=> "RD,Imm(RS1)", IWORD=>"1001 0000 RD   RS1                 Imm"},
    SW    => {FMT=> "RS2,Imm(RS1)",IWORD=>"0101 0000 RS1  RS2                Imm"},
    F     => {FMT=> "RD,RS1,RS2",  IWORD=>"0010 0000 RD   RS1  RS2  000000000000"},
    EQ    => {FMT=> "RD,RS1,RS2",  IWORD=>"0010 0001 RD   RS1  RS2  000000000000"},
    LT    => {FMT=> "RD,RS1,RS2",  IWORD=>"0010 0010 RD   RS1  RS2  000000000000"},
    LTE   => {FMT=> "RD,RS1,RS2",  IWORD=>"0010 0011 RD   RS1  RS2  000000000000"},
    T     => {FMT=> "RD,RS1,RS2",  IWORD=>"0010 1000 RD   RS1  RS2  000000000000"},
    NE    => {FMT=> "RD,RS1,RS2",  IWORD=>"0010 1001 RD   RS1  RS2  000000000000"},
    GTE   => {FMT=> "RD,RS1,RS2",  IWORD=>"0010 1010 RD   RS1  RS2  000000000000"},
    GT    => {FMT=> "RD,RS1,RS2",  IWORD=>"0010 1011 RD   RS1  RS2  000000000000"},
    FI    => {FMT=> "RD,RS1,Imm",  IWORD=>"1010 0000 RD   RS1                Imm"},
    EQI   => {FMT=> "RD,RS1,Imm",  IWORD=>"1010 0001 RD   RS1                Imm"},
    LTI   => {FMT=> "RD,RS1,Imm",  IWORD=>"1010 0010 RD   RS1                Imm"},
    LTEI  => {FMT=> "RD,RS1,Imm",  IWORD=>"1010 0011 RD   RS1                Imm"},
    TI    => {FMT=> "RD,RS1,Imm",  IWORD=>"1010 1000 RD   RS1                Imm"},
    NEI   => {FMT=> "RD,RS1,Imm",  IWORD=>"1010 1001 RD   RS1                Imm"},
    GTEI  => {FMT=> "RD,RS1,Imm",  IWORD=>"1010 1010 RD   RS1                Imm"},
    GTI   => {FMT=> "RD,RS1,Imm",  IWORD=>"1010 1011 RD   RS1                Imm"},
    BF    => {FMT=> "RS1,RS2,Imm", IWORD=>"0110 0000 RS1  RS2              PCRel"},
    BEQ   => {FMT=> "RS1,RS2,Imm", IWORD=>"0110 0001 RS1  RS2              PCRel"},
    BLT   => {FMT=> "RS1,RS2,Imm", IWORD=>"0110 0010 RS1  RS2              PCRel"},
    BLTE  => {FMT=> "RS1,RS2,Imm", IWORD=>"0110 0011 RS1  RS2              PCRel"},
    BEQZ  => {FMT=> "RS1,Imm",     IWORD=>"0110 0101 RS1  0000             PCRel"},
    BLTZ  => {FMT=> "RS1,Imm",     IWORD=>"0110 0110 RS1  0000             PCRel"},
    BLTEZ => {FMT=> "RS1,Imm",     IWORD=>"0110 0111 RS1  0000             PCRel"},
    BT    => {FMT=> "RS1,RS2,Imm", IWORD=>"0110 1000 RS1  RS2              PCRel"},
    BNE   => {FMT=> "RS1,RS2,Imm", IWORD=>"0110 1001 RS1  RS2              PCRel"},
    BGTE  => {FMT=> "RS1,RS2,Imm", IWORD=>"0110 1010 RS1  RS2              PCRel"},
    BGT   => {FMT=> "RS1,RS2,Imm", IWORD=>"0110 1011 RS1  RS2              PCRel"},
    BNEZ  => {FMT=> "RS1,Imm",     IWORD=>"0110 1101 RS1  0000             PCRel"},
    BGTEZ => {FMT=> "RS1,Imm",     IWORD=>"0110 1110 RS1  0000             PCRel"},
    BGTZ  => {FMT=> "RS1,Imm",     IWORD=>"0110 1111 RS1  0000             PCRel"},
    JAL   => {FMT=> "RD,Imm(RS1)", IWORD=>"1011 0000 RD   RS1              ShImm"},

    # B is implemented using BEQ
#    BR     => {FMT=>"Imm",        ITEXT=>["BEQ  R6,R6,Imm"]},
	# SUBI is implemented using ADDI
#	SUBI   => {FMT=>"RD,RS,Imm",  ITEXT=>["ADDI RD,RS,-Imm"]},
    # NOT is implemented using NOR
	NOT    => {FMT=>"RD,RS",      ITEXT=>["NAND RD,RS,RS"]},
	# BLT/BLE/BGT/BGE is implemented using LT/LE/GT/GE and BNE
#	BLT    => {FMT=>"RS1,RS2,Imm",ITEXT=>["LT   R6,RS1,RS2","BNE R6,Zero,Imm"]},
#	BLE    => {FMT=>"RS1,RS2,Imm",ITEXT=>["LE   R6,RS1,RS2","BNE R6,Zero,Imm"]},
#	BGT    => {FMT=>"RS1,RS2,Imm",ITEXT=>["GT   R6,RS1,RS2","BNE R6,Zero,Imm"]},
#	BGE    => {FMT=>"RS1,RS2,Imm",ITEXT=>["GE   R6,RS1,RS2","BNE R6,Zero,Imm"]},
	CALL   => {FMT=>"Imm\\\(RS1\\\)",ITEXT=>["JAL  RA,Imm(RS1)"]},
	RET    => {FMT=>"",              ITEXT=>["JAL  R9,0(RA)"]},
	JMP    => {FMT=>"Imm\\\(RS1\\\)",ITEXT=>["JAL  R9,Imm(RS1)"]},
    );

sub RmWs{
  my $inp=$_[0];
  $inp=~s/\s//g;
  return $inp;
}
# Size of the memory/register word (in bits)
$WordSize=32;
#Size of the instruction word
$InstSize=$WordSize;
# Size of the immediate field
$ImmSize=16;
%srnum =(
    SCS => "000",
    SIH => "001",
    SRA => "010",
    SII => "011",
    SR0 => "110",
    SR1 => "111",
    );

$RegNumSize=4;
%RegNames = (
	 0 =>  ["R0", "A0"],
	 1 =>  ["R1", "A1"],
	 2 =>  ["R2", "A2"],
	 3 =>  ["R3", "A3", "RV"],
	 4 =>  ["R4", "T0"],
	 5 =>  ["R5", "T1"],
	 6 =>  ["R6", "S0"],
	 7 =>  ["R7", "S1"],
	 8 =>  ["R8", "S2"],
	 9 =>  ["R9"],
   10 => ["R10"],
   11 => ["R11"],
   12 => ["R12","GP"  ],
   13 => ["R13","FP"  ],
   14 => ["R14","SP"  ],
   15 => ["R15","RA"  ],
  );  

# Returns a string of $bits binary digits that corresponds to $num
sub IntToBinStr{
  my ($num,$bits)=($_[0],$_[1]);
  my $binstr="";
  for(my $i=0;$i<$bits;$i++){
    $binstr=(($num&1)?"1":"0").$binstr;
	$num=($num>>1);
  }
  return $binstr;
}
# RegNums maps a register name to the corresponding bit-string 
%RegNums = ();
sub InitRegnums{
  print "In regnums now\n";
  foreach my $rnum ( keys %RegNames ){
	foreach my $rnam ( @{$RegNames{$rnum}} ){
	  $RegNums{$rnam}=&IntToBinStr($rnum,$RegNumSize);
	}
  }
}
&InitRegnums();

sub ToBin{
  my ($num,$bits,$wbits,$lnum)=($_[0],$_[1],$_[2],$_[3]);
  print "ToBin $num $bits $wbits $lnum\n";
  my $str="";
  my $curNum=int($num)&((1<<$wbits)-1);
  my $negRef=int(-1)&((1<<$wbits)-1);
  my $lastBit=0;
  for(my $bit=0;$bit<$bits;$bit++){
    $lastBit=($curNum&1);
    $str=$lastBit.$str;
    $curNum=$curNum>>1;
	$negRef=$negRef>>1;
  }
  ((($lastBit==0)&&($curNum==0))||(($lastBit==1)&&($curNum==$negRef)))
    or die "Line $lnum: Immediate operand $num too large to fit in $bits bits\n";
  return $str;
}

sub AsmInst{
   my ($op,$args,$pc,$line,$lnum)=($_[0],&RmWs($_[1]),$_[2],$_[3],$_[4]);
   my $sfmt=$opmap{$op}{FMT};
   my $mfmt=$opmap{$op}{IWORD};
   # Parse $args
   my ($argtail,$fmttail)=($args,$sfmt);
   while(true){
      (($argtail ne "") and ($fmttail ne ""))
         or last;
      $argtail=~/^([^\,\(\)]+)([\s\,\(\)]*)(.*)$/
         or die "Line $lnum: Invalid instruction format at $argtail\n";
      my $argnow=$1;
      my $argsep=$2;
      $argtail=$3;
      $fmttail=~/^([^\,\(\)]+)([\s\,\(\)]*)(.*)$/
         or die "Internal error at line $lnum: invalid FMT $fmttail for opcode $op\n";
      my $fmtnow=$1;
      my $fmtsep=$2;
      $fmttail=$3;
      if($fmtnow=~/^RD|RS1|RS2$/){
         # Arg should be a register name
         (exists $RegNums{$argnow})
            or die "Line $lnum: Invalid register name $argnow\n";
         $mfmt=~s/$fmtnow/$RegNums{$argnow}/g;
      }elsif($fmtnow=~/^SRD|SRS$/){
         # Arg should be a register name
         (exists $srnum{$argnow})
            or die "Line $lnum: Invalid system register name $argnow\n";
         $mfmt=~s/$fmtnow/$srnum{$argnow}/g;
      }elsif($fmtnow=~/^Imm$/){
         # Arg should be a label or constant
         my $imm=&LblGet($argnow);
         ($imm ne "") or
            $imm=&NumGet($argnow);
         ($imm ne "") or
            die "Line $lnum: Invalid immediate operand $argnow\n";
         # Take care of various uses of the immediate operand
         if($mfmt=~/ShImm/){
            my $immVal=&ToBin($imm/4,$ImmSize,$WordSize,$lnum);
            $mfmt=~s/ShImm/$immVal/eg;
         }elsif($mfmt=~/ImmHi/){
            my $immVal=&ToBin($imm>>16,$ImmSize,$WordSize,$lnum);
            $mfmt=~s/ImmHi/$immVal/eg;
         }elsif($mfmt=~/Imm/){
            my $immVal=&ToBin($imm,$ImmSize,$WordSize,$lnum);
            $mfmt=~s/Imm/$immVal/eg;
         }elsif($mfmt=~/PCRel/){
           my $relVal=&ToBin(($imm-($pc+4))/4,$ImmSize,$WordSize,$lnum);
           $mfmt=~s/PCRel/$relVal/eg;
         }
      }else{
         die "Internal error at line $lnum: invalid FMT $fmtnow for opcode $op\n";
      }
      ($argsep eq $fmtsep) or
         die "Line $lnum: Invalid syntax, expected $fmtsep but got $argsep\n";
   }
   print "Result: $op $args => $mfmt\n";
   # Remove spaces from the instruction word binary string
   $mfmt=~s/ //g;
   ($mfmt=~/^[01]{$InstSize}$/) or
      die "Internal error at line $lnum: IWORD fields not present in FMT for opcode $op\n"; 
   my $iword=0;
   while($mfmt ne ""){
     ($mfmt=~/^([01])(.*)$/) or
       die "Internal error at line $lnum: Non-binary result after FMT->IWORD substitution for opcode $op\n";
     $iword=$iword*2+int($1);
     $mfmt=$2;
   }
   print "Res: $iword\n";
   &SetMem($pc,$iword,$line,$lnum);
}

sub SubInst{
  my ($op,$args,$substfmt,$pc,$line,$lnum)=($_[0],$_[1],$_[2],$_[3],$_[4],$_[5]);
  my $argsfmt=$opmap{$op}{FMT};
  my @arglist=split(/\s*,\s*/,$args);
  my @fmtlist=split(/\s*,\s*/,$argsfmt);
  (@arglist == @fmtlist) or
    die "Line $lnum: Invalid number of arguments for pseudo-instruction $op\n"; 
  for(my $i=0;$i<@arglist;$i++){
	$substfmt=~s/$fmtlist[$i]/$arglist[$i]/g;
  }
  ($substfmt=~/^\s*([^\s]+)\s*(.*)$/) or
    die "Internal error at line $lnum: Pseudo-instruction translates to poorly-formatted instruction $line\n";
  my $opi=$1;
  my $argi=$2;
  (exists $opmap{$opi}) or
    die "Internal error at line $lnum: Pseudo-instruction translates to invalid opcode $opi\n";
  (exists $opmap{$opi}{IWORD}) or
    die "Internal error at line $lnum: Pseudo-instruction translates to pseudo-instruction $opi\n";
  &AsmInst($opi,$argi,$pc,$substfmt,$lnum);
}

local $lblfmt="[A-Z][0-9A-Z_]+";
my %lbl=();
sub LblGet{
  my $lname=$_[0];
  (exists $lbl{$lname})
    or return "";
  return $lbl{$lname};
}

my $numfmt="0X[0-9A-F]+|-?[0-9]+";
sub NumGet{
  my $numstr=$_[0];
  my $retVal;
  ($numstr=~/^($numfmt)$/) or
      return "";
  if(substr($numstr,0,2) eq "0X"){
    $retVal=hex(substr($numstr,2));
  }else{
    $retVal=int($numstr);
  }
  if($retVal & (1 << ( $WordSize-1 )))
  {
    $retVal|=((-1)^((1<<($WordSize-1))-1));
  }
  return $retVal;
}

sub SetMem{
  my ($addr,$val,$line,$lnum)=($_[0],$_[1],$_[2],$_[3]);
  (! exists $mem{$addr})
    or die "Line $lnum: Memory address $addr already filled\n";
  print "Set mem[$addr] to $val\n";
  $mem{$addr}=$val;
  $text{$addr}=$line;
}

my $InpFileName="Sorter2.a32";
my $OutFileName="Sorter2.mif";
if(@ARGV == 2){
  $InpFileName=$ARGV[0];
  $OutFileName=$ARGV[1];
}

for(my $pass=1;$pass<=2;$pass++){
print "PASS $pass START\n";
open(InFile,"< $InpFileName")
  or die "Can't open input file $InpFileName";
for(my $lnum=1;<InFile>;$lnum++){
  $line=uc($_);
  chomp($line);
  # Remove comment from the end of the line
  if($line=~/^([^;]*);.*$/){
    $line=$1;
  }
  if($line=~/^\s*$/){
    # Empty line
  }elsif($line=~/^\s*\.ORIG\s+($numfmt)\s*$/){
    $addr=&NumGet($1);
  }elsif($line=~/^\s*\.NAME\s+($lblfmt)\s*=\s*($numfmt)\s*$/){
    if($pass==1){
      (! exists $lbl{$1})
        or die "Line $lnum: Label $1 redefined";
    }else{
      (&LblGet($1) == &NumGet($2))
        or die "Line $lnum: Label $1 is pass 2 not the same as in pass 1\n";
    }
    $lbl{$1}=&NumGet($2);
    print "Pass $pass: Label $1 set to $lbl{$1}\n";
  }elsif($line=~/^\s*\.WORD\s+($numfmt|$lblfmt)\s*$/){
    if($pass==2){
      my $str=$1;
      if($str=~/^($numfmt)$/){
	my $num=&NumGet($str);
        ($num ne "") or
	  die "Line $lnum: Invalid numeric constant $str\n";
	&SetMem($addr,$num,$line,$lnum);
      }else{
	my $lbl=&LblGet($str);
        ($lbl ne "") or
	  die "Line $lnum: Label $str not defined\n";
        &SetMem($addr,$lbl,$line,$lnum);
      }
    }
    $addr+=4;
  }elsif($line=~/^\s*($lblfmt):\s*$/){
    if($pass==1){
      (! exists $lbl{$1})
        or die "Line $lnum: Label $1 redefined";
    }else{
      (&LblGet($1) == $addr)
        or die "Line $lnum: Label $1 is pass 2 not the same as in pass 1\n";
    }
    print "Pass $pass: Label $1 set to $addr\n";
    $lbl{$1}=$addr;
  }elsif($line=~/^\s*([^\s]+)\s*(.*)$/){
    my $opcode=$1;
    my $args=$2;
    (exists $opmap{$opcode})
      or die "Line $lnum: Invalid opcode $opcode\n";
    if(exists $opmap{$opcode}{IWORD}){
      ($pass==1) or
        &AsmInst($opcode,$args,$addr,$line,$lnum);
      $addr+=4;
    }elsif(exists $opmap{$opcode}{ITEXT}){
      my $expRef=$opmap{$opcode}{ITEXT};
      foreach my $subi ( @{$expRef} ){
        ($pass==1) or
		  &SubInst($opcode,$args,$subi,$addr,$line,$lnum);
		$addr+=4;
      }
    }else{
      die "Internal error: Incorrect opmap definition for opcode $opcode!\n";
    }
  }else{
    die "Don't know what line $line is supposed to do!\n";
  }
}
close(InFile);
print "PASS $pass DONE\n";
}

my $MemWords=2048;
my $AddrGran=1;
open(OutFile,"> $OutFileName")
  or die "Can't open output file $OutFileName";
print OutFile "WIDTH=$InstSize;\n";
print OutFile "DEPTH=$MemWords;\n";
print OutFile "ADDRESS_RADIX=HEX;\n";
print OutFile "DATA_RADIX=HEX;\n";
print OutFile "CONTENT BEGIN\n";
my $FillStart=0;
for(my $i=0;$i<$MemWords;$i++){
  if(exists $mem{$i*($WordSize/(8*$AddrGran))}){
    if($FillStart<$i){
      printf(OutFile "[%08x..%08x] : DEAD;\n",$FillStart,$i-1);
    }
    printf(OutFile "-- @ 0x%08x :",$i*($WordSize/(8*$AddrGran)));
    printf(OutFile " %s\n",$text{$i*($WordSize/(8*$AddrGran))});
    printf(OutFile "%08x : %08x;\n",$i,$mem{$i*($WordSize/(8*$AddrGran))});
    $FillStart=$i+1;
  }
}
if($FillStart<$MemWords){
  printf(OutFile "[%04x..%04x] : DEAD;\n",$FillStart,$MemWords-1);
}
print OutFile "END;\n";
close(OutFile);
