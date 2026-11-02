# Diakaki LQR Traffic Signal Control for Multi-Intersection SUMO Networks

MATLAB-based implementation of the Diakaki linear quadratic regulator (LQR) traffic signal control algorithm, interfaced with SUMO (Simulation of Urban MObility) via TraCI.

## Features
- Automated physical parameter extraction from SUMO network XML files.
- LQR-based optimal green time allocation for multi-intersection networks.
- Performance comparison between Fixed-Time control and Diakaki LQR.
- Queue length, waiting time, and queue imbalance metrics evaluation.
- Python-based route generation utility for customizable traffic demand.

## Requirements
- MATLAB (with Control System Toolbox)
- SUMO (Simulation of Urban MObility)
- Python 3.x (with `traci`)

## Usage
1. (Optional) Run `generate_routes.py` to regenerate route/demand XML files.
2. Run `extract_network_params.m` to parse network parameters.
3. Run `main.m` to simulate and compare Fixed-Time vs. Diakaki LQR controllers.
