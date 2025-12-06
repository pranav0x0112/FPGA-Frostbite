package part_2_tb;

import part_2::*;
import StmtFSM::*;
import Vector::*;
import RegFile::*;

(* synthesize *)
module mkTb_Day1_Part2(Empty);
    Day1_IFC dut <- mkDay1_Part2;
    
    Reg#(Bit#(32)) cycle <- mkReg(0);
    Reg#(Bit#(32)) instrIdx <- mkReg(0);
    
    // Memory to store instructions (bit 10 = direction, bits 9-0 = distance)
    RegFile#(Bit#(16), Bit#(11)) instructions <- mkRegFileLoad("input.hex", 0, 4499);
    
    rule countCycle;
        cycle <= cycle + 1;
    endrule
    
    // FSM to feed instructions from memory
    Stmt test = seq
        $display("Starting Day1 Part2 Test");
        dut.start();
        
        // Feed all instructions sequentially
        for (instrIdx <= 0; instrIdx < 4499; instrIdx <= instrIdx + 1) seq
            action
                Bit#(11) instr = instructions.sub(truncate(instrIdx));
                Dir direction = instr[10]; 
                Dist distance = instr[9:0];
                
                dut.put(direction, distance);
            endaction
        endseq
        
        $display("Finished loading 4499 instructions");
        await(dut.done());
        
        // again fancy ahh features twin
        action
            let result = dut.getZeroCount();
            $display("=====================================");
            $display("PART 2 RESULT: %0d", result);
            $display("EXPECTED:      6561");
            if (result == 6561)
                $display("TEST PASSED!");
            else
                $display("TEST FAILED!");
            $display("=====================================");
        endaction
        
        delay(10);
        $finish(0);
    endseq;
    
    mkAutoFSM(test);
endmodule

endpackage