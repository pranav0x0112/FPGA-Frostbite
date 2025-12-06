# Day 1: Circular Position Tracker - Implementation Report

## Problem Statement

The Day 1 challenge involves tracking a position on a circular array (0-99) that wraps around. Starting at position 50, we process a series of rotation instructions in the format `L<distance>` (left/counterclockwise) or `R<distance>` (right/clockwise), and count how many times the position lands on 0.

Part 1: Apply each rotation instruction as a single jump of the full distance.

Part 2: Break down each rotation into individual single-step movements, checking for zero crossings at each step.

## Part 1: Single-Jump Implementation

### Architecture Implemented

Part 1 uses a simple sequential architecture with a FIFO queue to decouple instruction feeding from processing. The FIFO acts as a buffer between the testbench and the processing logic, allowing them to operate independently. The core state includes a position register (0-99), a zero-crossing counter, and a processing enable flag.

### Design Logic

The processing rule continuously monitors the instruction queue. When an instruction is available and processing is enabled, the rule dequeues it and performs the complete rotation calculation in a single cycle - fetching, computing, and updating all happen atomically.

The key challenge was handling modulo arithmetic correctly in hardware. Since positions can move beyond the 0-99 range (both positive and negative), we need proper wrap-around logic. The approach converts both position and distance to signed 16-bit integers, performs addition or subtraction based on direction, then applies modulo 100.

### Bugs faced(fixed now tho): Type Conversion

The initial implementation used sign-extension when converting the unsigned distance values to signed integers. This caused a subtle bug where large distances (above 512) were incorrectly interpreted as negative numbers due to the sign bit, producing completely wrong results.

The fix was to use zero-extension instead, which preserves the unsigned semantics of distances. This ensures all distance values are treated as positive, allowing the arithmetic to work correctly.

### Performance

Part 1 processes one instruction per clock cycle, making it very efficient. For the 4,499 input instructions, the design completes in approximately the same number of cycles.

## Part 2: Step-by-Step Implementation

### Architecture Overview

Part 2 requires a fundamentally different approach since each rotation must be broken into individual steps. This is implemented as a multi-cycle state machine with three states defined (IDLE, PROCESSING, and STEPPING), though only IDLE and STEPPING are actively used in the implementation.

The state machine maintains additional registers beyond Part 1: the current state, the direction being processed, and a counter for remaining steps.

### State Machine Logic

Fetch Stage (IDLE -> STEPPING): When idle and an instruction is available, the machine dequeues it, stores the direction, initializes the step counter with the distance, and transitions to STEPPING. Zero-distance instructions are handled as no-ops.

Stepping Stage (STEPPING -> STEPPING/IDLE): This is where the actual work happens. The machine moves the position by exactly one unit in the stored direction, checking for wraparound at boundaries (0 and 99). After each single step, it checks if the new position is zero and increments the counter if so.

The step counter is decremented after each move. When it reaches one, the machine returns to IDLE to fetch the next instruction. Otherwise, it stays in STEPPING to continue processing the current rotation.

### Wraparound Logic

Unlike Part 1, Part 2 uses explicit boundary checking rather than modulo arithmetic. For rightward moves, if the position is 99, it wraps to 0; otherwise it increments. For leftward moves, if the position is 0, it wraps to 99; otherwise it decrements. This is simpler and more efficient than modulo for single-step movements.

## Testbench Architecture

### Input Preprocessing Challenge

Bluespec SystemVerilog doesn't support runtime file parsing with loops in action blocks, which created a significant challenge for loading the 4,499 test instructions. The solution was to preprocess the input data.

A Python script converts the text input file into a hex memory initialization file. Each instruction is encoded into 11 bits: bit 10 represents the direction (1=Right, 0=Left), and bits 9-0 store the distance. This encoding is written as hex values to a file.

The testbench then uses a RegFile with `mkRegFileLoad` to load this hex file at elaboration time. This approach works around BSV's file I/O limitations by moving the parsing complexity to preprocessing.

### Test Flow

The testbench uses `StmtFSM` to create a clean sequential test flow. It initializes the design, feeds all 4,499 instructions using a for-loop that iterates over the RegFile, waits for the done signal, and finally checks the result against the expected value.

The for-loop creates a sequence where each iteration reads one instruction from the RegFile memory, extracts the direction (bit 10) and distance (bits 9-0), and calls the put method. This happens sequentially over multiple cycles - one instruction fed per cycle.

## Results

Both parts successfully pass their test cases:

- **Part 1:** Expected 1145, Got 1145
- **Part 2:** Expected 6561, Got 6561

## Potential Optimizations

For Part 1, pipelining could allow multiple instructions to be processed concurrently.

For Part 2, the step-by-step logic could be optimized when the position is far from zero by taking larger jumps, then switching to single steps near the boundaries. This would maintain correctness while improving performance for large rotations.

Both designs could be parameterized to support different circular buffer sizes rather than the hardcoded 100-element array.