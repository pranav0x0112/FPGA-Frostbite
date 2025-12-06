package part_2;

import FIFOF::*;

typedef Bit#(1) Dir;   // 0=Left, 1=Right
typedef Bit#(10) Dist;
typedef Bit#(7) Pos;    // Position 0-99 (need 7 bits for values up to 127)

typedef enum {
    IDLE,
    PROCESSING,
    STEPPING
} State deriving (Bits, Eq);

interface Day1_IFC;
    method Action put(Dir d, Dist x);
    method Bit#(16) getZeroCount();
    method Bool done();
    method Action start();
endinterface

module mkDay1_Part2(Day1_IFC);
    Reg#(Pos) pos <- mkReg(50);
    Reg#(Bit#(16)) zeroCount <- mkReg(0);
    Reg#(State) state <- mkReg(IDLE);
    
    Reg#(Dir) currentDir <- mkReg(0);
    Reg#(Dist) stepsRemaining <- mkReg(0);
    
    FIFOF#(Tuple2#(Dir, Dist)) instructionQ <- mkFIFOF;
    
    // Rule to fetch next instruction
    rule fetchInstruction (state == IDLE && instructionQ.notEmpty);
        let {d, x} = instructionQ.first;
        instructionQ.deq;
        
        if (x == 0) begin
            state <= IDLE;
        end else begin
            currentDir <= d;
            stepsRemaining <= x;
            state <= STEPPING;
        end
    endrule
    
    // Rule to step through rotation one click at a time
    rule stepRotation (state == STEPPING);
        Pos newPos;
        
        if (currentDir == 1) begin  
            newPos = (pos == 99) ? 0 : pos + 1;
        end else begin 
            newPos = (pos == 0) ? 99 : pos - 1;
        end
        
        pos <= newPos;
        
        if (newPos == 0)
            zeroCount <= zeroCount + 1;
        
        if (stepsRemaining == 1) begin
            state <= IDLE;
        end else begin
            stepsRemaining <= stepsRemaining - 1;
        end
    endrule
    
    method Action put(Dir d, Dist x) if (state != PROCESSING);
        instructionQ.enq(tuple2(d, x));
    endmethod
    
    method Bit#(16) getZeroCount();
        return zeroCount;
    endmethod
    
    method Bool done();
        return (state == IDLE) && !instructionQ.notEmpty;
    endmethod
    
    method Action start();
        state <= IDLE;
        pos <= 50;
        zeroCount <= 0;
        stepsRemaining <= 0;
    endmethod
endmodule

endpackage