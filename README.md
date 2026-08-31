# Replication Package: High-Dimensional Learning in Finance

This repository contains the complete replication package (code, datasets, and interactive Google Colab notebooks) for the paper:

> **"High-Dimensional Learning in Finance"**  
> *Hasan Fallahgoul* (Monash University)

---

## 📋 Replication Overview

The replication package is divided into two self-contained parts:

1. **Python & Interactive Google Colab Notebooks**: Empirical feature map stability tests, kernel approximation error analysis, and Section 4.5 full Monte Carlo simulations.
2. **MATLAB Routines (`matlab/`)**: Cross-Validation (LOOCV, OSACV) and Oracle prediction performance comparisons for Standardized vs. Unstandardized Random Fourier Features (Section 3.5.1).

---

## 🚀 Part 1: Interactive Google Colab Notebooks (Python)

You can run any of the Python notebooks directly in your browser without installing anything locally by clicking the corresponding **Open in Colab** badge below:

| # | Notebook | Paper Output / Exhibit | Google Colab |
|---|:---|:---|:---:|
| **1** | [`01_Empirical_Analysis_Assumption_3_Violation.ipynb`](01_Empirical_Analysis_Assumption_3_Violation.ipynb) | **Assumption 3 Stability Test**: Empirical evaluation of feature map variation across rolling windows under KMZ (2024) within-window standardization. Replicates `same_input_different_output.pdf` (12-panel figure) and summary stability ratios. | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/hfallahgoul/High-Dimensional-Learning-in-Finance/blob/main/01_Empirical_Analysis_Assumption_3_Violation.ipynb) |
| **2** | [`02_Kernel_Convergence_Breakdown.ipynb`](02_Kernel_Convergence_Breakdown.ipynb) | **Kernel Approximation Error**: Mean absolute kernel approximation error vs. true Gaussian kernel for Standard RFF vs. KMZ RFF ($P \in [100, 12000]$). Replicates `kernel_approximation_error.pdf`. | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/hfallahgoul/High-Dimensional-Learning-in-Finance/blob/main/02_Kernel_Convergence_Breakdown.ipynb) |
| **3** | [`03_Sim45_Monte_Carlo_Extensions.ipynb`](03_Sim45_Monte_Carlo_Extensions.ipynb) | **Section 4.5 Monte Carlo Extensions**: Out-of-sample $R^2$, Sign Sharpe, and Linear Sharpe across $T \in [6, 398]$ under i.i.d. and AR(1) DGPs, and varying signal levels. Replicates Figures A–D (`fig_r2_baseline.pdf`, `fig_sharpe.pdf`, `fig_iid_vs_ar1.pdf`, `fig_sensitivity.pdf`) and paper calibration metrics. | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/hfallahgoul/High-Dimensional-Learning-in-Finance/blob/main/03_Sim45_Monte_Carlo_Extensions.ipynb) |

### Running Python Locally:
1. **Clone the repository**:
   ```bash
   git clone https://github.com/hfallahgoul/High-Dimensional-Learning-in-Finance.git
   cd High-Dimensional-Learning-in-Finance
   ```
2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
3. **Launch Jupyter**:
   ```bash
   jupyter notebook
   ```

---

## 🔬 Part 2: Cross-Validation & Oracle Replication (MATLAB)

The [`matlab/`](matlab/) directory contains the complete MATLAB replication code for **Section 3.5.1** of the paper (comparing prediction accuracy for Standardized vs. Unstandardized RFF under Leave-One-Out Cross-Validation, Out-of-Sample-Adjusted Cross-Validation, and the Oracle procedure).

### Structure:
* **`matlab/run_all.m`**: Master execution script that runs the entire pipeline (LOOCV, OSACV, and Oracle procedures) and outputs all comparison exhibits and tables.
* **`matlab/readme.m`**: Detailed script-level documentation and execution notes.
* **`matlab/functions_CV/`**: Prediction, evaluation, and exhibit generation routines for LOOCV and OSACV.
* **`matlab/functions_oracle/`**: Prediction, evaluation, and exhibit generation routines for the Oracle procedure.
* **`matlab/KMZ_based_local.functions/`**: Local helper functions, Ridge SVD solvers, and base dataset (`KMZ_GYdata.mat`).

### How to Run:
1. Open MATLAB and set your current working directory to the `matlab/` folder:
   ```matlab
   cd matlab
   ```
2. Run the master script from the MATLAB command window:
   ```matlab
   run_all
   ```
*(Note: By default, `run_all.m` runs $nSim = 1000$ using parallel computing (`parfor`). To run a fast structural test, you can set `nSim = 1` inside `run_all.m`).*

---

## 📁 Repository File Tree

```text
High-Dimensional-Learning-in-Finance/
├── 01_Empirical_Analysis_Assumption_3_Violation.ipynb  # Feature map stability test
├── 02_Kernel_Convergence_Breakdown.ipynb             # Kernel approximation error breakdown
├── 03_Sim45_Monte_Carlo_Extensions.ipynb             # Section 4.5 full Monte Carlo simulations
├── PredictorData2021.csv                             # Goyal-Welch predictor dataset (1926–2020)
├── requirements.txt                                  # Python dependencies
├── LICENSE                                           # MIT Open-Source License
├── README.md                                         # Master documentation
│
└── matlab/                                           # MATLAB replication (Section 3.5.1)
    ├── run_all.m                                     # Master execution script
    ├── readme.m                                      # MATLAB documentation
    ├── KMZ_based_local.functions/                    # Core helpers & KMZ data
    ├── functions_CV/                                 # LOOCV & OSACV routines
    └── functions_oracle/                             # Oracle procedure routines
```

---

## 📊 Dataset Description

* **`PredictorData2021.csv`**: Monthly Goyal and Welch (2021) return predictor dataset spanning 1926:01 to 2020:12 (1,140 observations, 15 economic predictors including dividend-price ratio `dp`, dividend yield `dy`, earnings-price ratio `ep`, book-to-market `b/m`, net equity expansion `ntis`, default yield spread `dfy`, term spread `tms`, default return spread `dfr`, stock variance `svar`, inflation `infl`, lagged excess return `lag_exret`, etc.).

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
