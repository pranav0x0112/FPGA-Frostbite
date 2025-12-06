BSC = bsc

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
	./$(PART1_EXE)

# Build and run Part 2
.PHONY: part2
part2: $(PART2_EXE)
	./$(PART2_EXE)

# Compile Part 1
$(PART1_EXE): $(PART1_RTL) $(PART1_TB) | $(BDIR) $(SIMDIR)
	$(BSC) $(SIMFLAGS) -bdir $(BDIR) -simdir $(SIMDIR) -g mkTb_Day1_Part1 $(PART1_TB)
	$(BSC) $(LINKFLAGS) -bdir $(BDIR) -simdir $(SIMDIR) -e mkTb_Day1_Part1 -o $(PART1_EXE)

# Compile Part 2
$(PART2_EXE): $(PART2_RTL) $(PART2_TB) | $(BDIR) $(SIMDIR)
	$(BSC) $(SIMFLAGS) -bdir $(BDIR) -simdir $(SIMDIR) -g mkTb_Day1_Part2 $(PART2_TB)
	$(BSC) $(LINKFLAGS) -bdir $(BDIR) -simdir $(SIMDIR) -e mkTb_Day1_Part2 -o $(PART2_EXE)

# Create build directories
$(BDIR) $(SIMDIR):
	mkdir -p $(BDIR) $(SIMDIR)

# Clean everything
.PHONY: clean
clean:
	rm -rf $(BUILDDIR) $(PART1_EXE) $(PART2_EXE) *.bo *.ba
	@echo "  help     - Show this help message"