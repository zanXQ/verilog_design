Top=ALU

.PHONY: sim
sim:	$(Top)_tb.v $(Top).v
	iverilog -o dump.vvp $(Top)_tb.v
	vvp dump.vvp

.PHONY: wave
wave:	$(Top).vcd
	gtkwave $(Top)_tb.vcd

$(Top).vcd: 
	make sim
	
.PHONY: netlist
netlist: $(Top).svg
	inkscape $(Top).svg

$(Top).svg: $(Top).json
	netlistsvg -o $(Top).svg $(Top).json

$(Top).json: $(Top).v
	yosys -p "prep -top $(Top); write_json $(Top).json" $(Top).v

.PHONY: lint
lint: $(Top).v $(Top)_tb.v
	iverilog $(Top).v
	iverilog $(Top)_tb.v

.PHONY: clean
clean:
	rm -f *.vcd
	rm -f *.svg
	rm -f *.json
	rm -f *.vvp
