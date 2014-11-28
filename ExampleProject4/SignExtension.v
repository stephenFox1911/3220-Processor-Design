module SignExtension(dIn, dOut);
  parameter IN_BIT_WIDTH;
  parameter OUT_BIT_WIDTH;
  
  input [(IN_BIT_WIDTH-1):0] dIn;
  output[(OUT_BIT_WIDTH-1):0] dOut;
  
  assign dOut = {{(OUT_BIT_WIDTH - IN_BIT_WIDTH){dIn[IN_BIT_WIDTH-1]}}, dIn};
endmodule
