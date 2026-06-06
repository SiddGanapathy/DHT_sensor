# DHT_sensor

FPGA/Verilog implementation of a DHT sensor interface and simulation environment using Quartus and ModelSim.

## Overview

This project contains the RTL design, Quartus project files, and simulation setup for interfacing with a DHT temperature/humidity sensor.

The repository includes:

- RTL Verilog source files
- Quartus project configuration
- ModelSim simulation files
- Generated simulation scripts and reports

---

## Repository Structure

```text
DHT_sensor/
│
├── t2a_dht/
│   ├── simulation/
│   │   └── modelsim/
│   │       ├── *.do
│   │       ├── vsim.wlf
│   │       └── simulation files
│   │
│   ├── *.v
│   ├── *.qpf
│   ├── *.qsf
│   ├── *.qws
│   └── nativeLinkSimulation.rpt
│
└── README.md
```

---

## Tools Used

- Intel Quartus Prime
- ModelSim
- Verilog HDL

---

## Features

- DHT sensor communication interface
- RTL simulation support
- Quartus project setup
- ModelSim automation scripts

---

## Running Simulation

1. Open the project in Quartus.
2. Compile the design.
3. Open ModelSim.
4. Run the generated `.do` simulation script.

Example:

```tcl
do t2a_dht_run_msim_rtl_verilog.do
```

---

## Future Improvements

- FPGA hardware validation
- FSM optimization
- Parameterized timing support
- Support for additional DHT variants

---
