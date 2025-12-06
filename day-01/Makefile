BSC = bsc

# Ensure we use the correct x86-64 assembler, not RISC-V
export PATH := /usr/bin:$(PATH)

# Directories
RTL_DIR = rtl
TB_DIR = tb
BUILDDIR = build
BDIR = $(BUILDDIR)/bdir
SIMDIR = $(BUILDDIR)/simdir

# Simulation flags
SIMFLAGS = -sim -u -p $(RTL_DIR):$(TB_DIR):+
LINKFLAGS = -sim

# Source files
PART1_RTL = $(RTL_DIR)/part_1.bsv
PART1_TB = $(TB_DIR)/part_1_tb.bsv
PART2_RTL = $(RTL_DIR)/part_2.bsv
PART2_TB = $(TB_DIR)/part_2_tb.bsv

# Output executables
PART1_EXE = sim_part1
PART2_EXE = sim_part2

# Default target - run both parts
.PHONY: all
all: part1 part2

# Build and run Part 1
.PHONY: part1
part1: $(PART1_EXE)
	@echo "======================================"
	@echo "Running Part 1..."
	@echo "======================================"
	./$(PART1_EXE)

# Build and run Part 2
.PHONY: part2
part2: $(PART2_EXE)
	@echo "======================================"
	@echo "Running Part 2..."
	@echo "======================================"
	./$(PART2_EXE)

# Compile Part 1
$(PART1_EXE): $(PART1_RTL) $(PART1_TB) | $(BDIR) $(SIMDIR)
	@echo "Compiling Part 1..."
	$(BSC) $(SIMFLAGS) -bdir $(BDIR) -simdir $(SIMDIR) -g mkTb_Day1_Part1 $(PART1_TB)
	$(BSC) $(LINKFLAGS) -bdir $(BDIR) -simdir $(SIMDIR) -e mkTb_Day1_Part1 -o $(PART1_EXE)

# Compile Part 2
$(PART2_EXE): $(PART2_RTL) $(PART2_TB) | $(BDIR) $(SIMDIR)
	@echo "Compiling Part 2..."
	$(BSC) $(SIMFLAGS) -bdir $(BDIR) -simdir $(SIMDIR) -g mkTb_Day1_Part2 $(PART2_TB)
	$(BSC) $(LINKFLAGS) -bdir $(BDIR) -simdir $(SIMDIR) -e mkTb_Day1_Part2 -o $(PART2_EXE)

# Create build directories
$(BDIR) $(SIMDIR):
	mkdir -p $(BDIR) $(SIMDIR)

# Run only Part 1
.PHONY: run1
run1: $(PART1_EXE)
	./$(PART1_EXE)

# Run only Part 2
.PHONY: run2
run2: $(PART2_EXE)
	./$(PART2_EXE)

# Compile only (no run)
.PHONY: compile
compile: $(PART1_EXE) $(PART2_EXE)

# Clean everything
.PHONY: clean
clean:
	rm -rf $(BUILDDIR)
	rm -f $(PART1_EXE) $(PART2_EXE)
	rm -f *.bo *.ba
	rm -f schedule_* dump_*

# Clean and rebuild
.PHONY: rebuild
rebuild: clean all

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all      - Build and run both parts (default)"
	@echo "  part1    - Build and run Part 1"
	@echo "  part2    - Build and run Part 2"
	@echo "  run1     - Run Part 1 (assumes already built)"
	@echo "  run2     - Run Part 2 (assumes already built)"
	@echo "  compile  - Compile both parts without running"
	@echo "  clean    - Remove all build artifacts"
	@echo "  rebuild  - Clean and build everything"
	@echo "  help     - Show this help message"