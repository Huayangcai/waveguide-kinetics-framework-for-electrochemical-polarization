# waveguide-kinetics-framework-for-electrochemical-polarization

A theory-neutral **waveguide kinetics** framework that reinterprets electrochemical polarization curves as a power-flow-like response, enabling a compact **modal (multi-channel) representation** of interfacial kinetics under a unified waveguide-invariant mapping.

This repository currently provides two MATLAB scripts used to generate the paper figures:

* **Figure01.m**: conceptual two-mode kinetics visualization (flux-based “Scheme A”).
* **Figure02.m**: summary plotting utility that reads precomputed `.mat` outputs (no refit) and assembles a multi-row figure.
* **Universal_Waveguide_Fit.m**: Universal Waveguide Electrochemistry Analysis Program

---

## Contents

* `Figure01.m`
  Generates a **3×2** figure (cathodic vs anodic columns) illustrating:

  1. bounded current-like proxy (\tilde{j}) for Mode A, Mode B, and total response,
  2. the feedback ratio (\rho(\tilde{\eta})) (flux-based),
  3. the power-flow density metric (\Pi_{\mathrm{dens}}(\tilde{\eta})) and its optimum markers.
     Output: `Figure01.png` (600 dpi).

* `Figure02.m`
  Reads **4 saved MAT files** (one dataset per row) and generates a **4×2** summary figure:

  * left panel: raw data + stored fit curves (no refit),
  * right panel: (\Pi_{\mathrm{dens}}(\tilde{\eta})) + optimum markers (no refit).
    Output: user-specified PNG (default: `Figure 02.png`, 600 dpi).
    
* `Universal_Waveguide_Fit.m`
  * The program automatically detects the input data format and processes it
  * accordingly. It supports four different case formats:
  *  - Case01: CSV format with pH, U (vs SHE), and current density columns
  *   - Case02: Excel format with grouped potential/current density pairs
  *   - Case03: Excel format with pH grouping and catalyst information
  *   - Case04: Excel format with block-structured data
  *
  * Usage:
  *   Universal_Waveguide_Fit()              % Interactive file selection
  *   Universal_Waveguide_Fit(filePath)     % Use specified file
  *
  * Output:
  *   - Optimized parameters saved to text files
  *   - Figures saved as PNG and FIG formats
  *   - Data saved as MAT files
---

## Requirements

* MATLAB **R2019b+** (recommended R2020b+), mainly for `tiledlayout`.
* No special toolboxes are required for plotting.
* For `Figure02.m`, you need `.mat` files containing a variable `OUT` with the expected fields (see below).

---

## Quick Start

### 1) Generate Figure 01 (conceptual two-mode kinetics)

1. Place `Figure01.m` in your working directory (or add it to MATLAB path).
2. Run:

```matlab
Figure01
```

3. The script will save:

* `Figure01.png` (600 dpi) in the current folder.

> To change parameter sets (mode strengths, asymmetry (\xi), growth rate (\lambda), ranges of (\tilde{\eta}), etc.), edit the `cfg` struct at the top of `Figure01.m`.

---

### 2) Generate Figure 02 (summary figure from saved `.mat` results)

`Figure02.m` assembles a 4×2 multi-row summary from **exactly four** MAT files.

#### Default usage

```matlab
Figure02
```

By default it expects these files in the working directory (or script directory):

* `Figure_data01.mat`, `Figure_data02.mat`, `Figure_data03.mat`, `Figure_data04.mat`

#### Custom usage

```matlab
matFiles = {'Figure_data01.mat','Figure_data02.mat','Figure_data03.mat','Figure_data04.mat'};
Figure02(matFiles, 'Figure02.png');
```

---

## Input `.mat` format expected by `Figure02.m`

Each MAT file must contain a variable named `OUT`. The script expects:

### Required

* `OUT.RES` : array of structs (raw data per group)

  * `OUT.RES(g).eta` : raw overpotential (V)
  * `OUT.RES(g).j`   : raw current density (e.g., mA cm(^{-2}))

* `OUT.D` : cell array (or struct array convertible to cell), one cell per group
  Typical fields used:

  * `OUT.D{g}.etaFine` : fine grid (V)
  * `OUT.D{g}.jFit`    : fitted curve on `etaFine`
  * `OUT.D{g}.eta_t`       : dimensionless overpotential (\tilde{\eta})
  * `OUT.D{g}.Pi_dens_t`   : (\Pi_{\mathrm{dens}}(\tilde{\eta}))
  * `OUT.D{g}.etaStar_t`   : optimal (\tilde{\eta}^*) (optional but recommended)
  * `OUT.D{g}.PiStar_t`    : optimal (\Pi_{\mathrm{dens}}^*) (optional but recommended)

## Output

Both scripts export **high-resolution PNG** using:

* `-r600` (600 dpi)

Files are saved to the current working directory unless you modify the output path.

---

## Citation

If you use this code in academic work, please cite the associated papers:
（1）H. Cai, B. Chen, A universal waveguide mass-energy relation for lossy one-dimensional waves in nature. arXiv, https://doi.org/10.48550/arXiv.2602.04171 (2026).
（2）B. Chen, H. Cai, A waveguide kinetics framework for electrochemical polarization. arXiv, http://arxiv.org/abs/2602.05455 (2026).
## License

Attribution-ShareAlike 3.0 Unported

## Contact

For questions, issues, or reproducibility requests, please open a GitHub Issue in this repository or contact: caihy7@mail.sysu.edu.cn.


