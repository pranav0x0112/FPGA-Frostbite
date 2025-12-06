package part_1;

import FIFOF::*;

typedef Bit#(1) Dir;  // 0=Left, 1=Right
typedef Bit#(10) Dist; 
typedef Bit#(7) Pos;   // Position 0-99 (need 7 bits for values up to 127)

interface Day1_IFC;
    method Action put(Dir d, Dist x);
    method Bit#(16) getZeroCount();
    method Bool done();
    method Action start();
endinterface

module mkDay1_Part1(Day1_IFC);
    Reg#(Pos) pos <- mkReg(50);
    Reg#(Bit#(16)) zeroCount <- mkReg(0);
    Reg#(Bool) processing <- mkReg(True);
    
    FIFOF#(Tuple2#(Dir, Dist)) instructionQ <- mkFIFOF;
    
    // Rule to process one instruction at a time
    rule processInstruction (processing && instructionQ.notEmpty);
        let {d, x} = instructionQ.first;
        instructionQ.deq;
        
        Int#(16) temp;
        Pos newPos;
        
        // Convert unsigned distance to signed for arithmetic
        Int#(16) distance = unpack(zeroExtend(x));
        Int#(16) position = unpack(zeroExtend(pos));
        
        if (d == 1) begin  
            temp = position + distance;
        end else begin  
            temp = position - distance;
        end
        
        // handle negative numbers correctly lol
        Int#(16) mod_result = temp % 100;
        if (mod_result < 0)
            mod_result = mod_result + 100;
        
        newPos = truncate(pack(mod_result));
        pos <= newPos;
        
        if (newPos == 0)
            zeroCount <= zeroCount + 1;
    endrule
    
    method Action put(Dir d, Dist x) if (processing);
        instructionQ.enq(tuple2(d, x));
    endmethod
    
    method Bit#(16) getZeroCount();
        return zeroCount;
    endmethod
    
    method Bool done();
        return !instructionQ.notEmpty && processing;
    endmethod
    
    method Action start();
        processing <= True;
        pos <= 50;
        zeroCount <= 0;
    endmethod
endmodule

endpackage