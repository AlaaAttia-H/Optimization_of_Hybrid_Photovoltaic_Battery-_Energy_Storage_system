# Hybrid Photovoltaic-Battery Energy Storage Sizing Optimization

## Overview

This project compares several metaheuristic optimization algorithms for sizing a hybrid photovoltaic-battery energy storage system. The goal is to find the optimal number of PV panels and batteries required to supply electricity to 100 houses in Egypt while minimizing cost and power-supply deficit.

The optimization problem considers both economic and reliability objectives, mainly the Total Life Cycle Cost `TLCC` and the Deficit Power Supply Probability `DPSP`.

## Project Objectives

- Model a hybrid PV-battery energy storage system.
- Optimize the number of PV panels and batteries.
- Minimize total life cycle cost.
- Minimize deficit power supply probability.
- Compare the performance of different metaheuristic algorithms.
- Analyze convergence, execution time, and consistency across runs.

## System Description

The system consists of:

- PV panels
- Battery storage bank
- Inverter
- Load demand from 100 houses
- Dump load for excess generated energy

When the generated PV energy is higher than the load demand, the excess energy is stored in the battery. If the battery is fully charged, the extra energy is dumped into a dump load. When PV production is lower than the demand, the battery compensates for the deficit.

## Optimization Algorithms

The following metaheuristic algorithms were implemented and compared:

- Simulated Annealing `SA`
- Genetic Algorithm `GA`
- Grey Wolf Optimization `GWO`
- Bat Algorithm `BA`

## Decision Variables

| Variable | Description |
|---|---|
| `Npv` | Number of PV panels |
| `Nbat` | Number of batteries |

## Objective Function

The objective function minimizes the total system cost while penalizing the deficit power supply probability.

```text
Minimize: TLCC + DPSP × 10^7
```

Where:

- `TLCC` is the Total Life Cycle Cost.
- `DPSP` is the Deficit Power Supply Probability.

## Constraints

| Parameter | Minimum | Maximum |
|---|---:|---:|
| Number of PV panels `Npv` | 100 | 1500 |
| Number of batteries `Nbat` | 100 | 1000 |
| DPSP | 0 | 0.05 |

## System Parameters

The system model includes parameters for:

- PV panel rated power
- PV panel cost
- PV panel maintenance cost
- Inverter rated power
- Inverter efficiency
- Inverter cost
- Battery nominal capacity
- Battery charge/discharge efficiency
- Battery depth of discharge
- Battery self-discharge
- Battery cost
- Load demand
- Generated PV energy

## Technologies Used

- MATLAB
- Metaheuristic optimization
- Renewable energy system modeling
- Cost modeling
- Performance analysis
- Data visualization

## MATLAB Implementation

Each algorithm was implemented and run multiple times. The best solution for each run was recorded and compared using different performance metrics.

The comparison included:

- DPSP
- TLCC
- Number of PV panels
- Number of batteries
- Best fitness value
- Execution time
- Mean value
- Standard deviation
- Cost function convergence

## Results Summary

The algorithms produced feasible sizing results, but they differed in execution time, consistency, convergence behavior, and final fitness value.

### Main Findings

- Simulated Annealing achieved the best optimal fitness value.
- Grey Wolf Optimization produced the most consistent results.
- Genetic Algorithm showed more fluctuation in the number of PV panels.
- Bat Algorithm converged quickly but had a long execution time due to the number of iterations.
- Around 100 batteries appeared to be the most common optimal battery-bank size across the algorithms.

## Example Performance Results

| Algorithm | Example Optimal Solution `(Npv, Nbat)` | Optimal Fitness Value |
|---|---:|---:|
| Simulated Annealing | `(756, 103)` | `91999` |
| Genetic Algorithm | `(795, 100)` | `97886` |
| Grey Wolf Optimization | `(755, 100)` | `95931` |
| Bat Algorithm | `(756, 109)` | `96332` |

## Algorithm Comparison

### Simulated Annealing

Simulated Annealing achieved the best optimal fitness value. It was also the fastest algorithm among the tested methods. However, it showed slightly more variation than Grey Wolf Optimization.

### Genetic Algorithm

The Genetic Algorithm was able to reach feasible solutions, but it showed more fluctuation in the number of PV panels and produced a higher fitness value compared to the other methods.

### Grey Wolf Optimization

Grey Wolf Optimization produced highly consistent results. It reached almost the same solution across different runs, making it the most stable algorithm in this comparison. However, it had a longer execution time.

### Bat Algorithm

The Bat Algorithm converged very quickly in terms of iteration count, but its total execution time was high. This suggests that fewer iterations could be used in future testing to reduce runtime.

## How to Run

Update the script names according to the actual repository.

Open MATLAB and run:

```matlab
main
```

or run each algorithm separately:

```matlab
run_simulated_annealing
run_genetic_algorithm
run_grey_wolf_optimization
run_bat_algorithm
```

## Notes

This project was completed as part of the Optimization Techniques for Multi-Cooperative Systems course at the German University in Cairo.

## Author

Alaa Ali
