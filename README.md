# waveguide-kinetics-framework-for-electrochemical-polarization

A **waveguide-kinetics framework** for electrochemical polarization that reinterprets interfacial current–overpotential relations as a **power-flow–like response** in a lossy one-dimensional waveguide.
The framework enables a compact **modal (multi-channel) decomposition** of electrochemical kinetics and a unified **waveguide-invariant mapping** between current, feedback, and power-transfer metrics.

This repository provides **three MATLAB programs** used in the associated papers to (i) illustrate the conceptual two-mode kinetics, (ii) assemble multi-dataset summary figures without refitting, and (iii) perform **universal waveguide-based fitting and analysis** of experimental polarization data.

---

## Contents

### `Figure01.m`

**Conceptual two-mode waveguide kinetics visualization (flux-based “Scheme A”)**

Generates a **3 × 2** figure (cathodic vs anodic columns) illustrating:

1. **Bounded current-like proxy** (\tilde{j}(\tilde{\eta}))

   * Mode A
   * Mode B
   * Total response

2. **Feedback ratio** (\rho(\tilde{\eta}))

   * Flux-based definition derived from the waveguide invariant

3. **Power-flow density metric** (\Pi_{\mathrm{dens}}(\tilde{\eta}))

   * With automatically identified optimum operating points

**Output**

* `Figure01.png` (600 dpi)

This script is **theoretical and self-contained** and does **not** read external data files.

---

### `Figure02.m`

**Multi-dataset summary plotting utility (no refit)**

Reads **four precomputed `.mat` files** (one dataset per row) and assembles a **4 × 2** summary figure:

* **Left column**: raw polarization data + stored fitted curves
* **Right column**: (\Pi_{\mathrm{dens}}(\tilde{\eta})) with optimum markers

All curves and markers are plotted **exactly as stored** in the MAT files —
**no refitting or re-optimization is performed**.

**Output**

* User-specified PNG (default: `Figure02.png`, 600 dpi)

This script is intended for **figure assembly and comparison across systems**.

---

### `Universal_Waveguide_Fit.m`

**Universal Waveguide Electrochemical Analysis Program**

A full analysis pipeline that:

* Automatically **detects the input data format**
* Performs **waveguide-kinetics fitting**
* Extracts **modal parameters**, feedback metrics, and power-flow quantities
* Saves **figures, fitted data, and MAT files** compatible with `Figure02.m`

#### Supported input formats

The program automatically recognizes **four data layouts**:

* **Case 01**
  CSV format with columns:

  * pH
  * Potential (vs SHE)
  * Current density

* **Case 02**
  Excel format with grouped potential–current pairs

* **Case 03**
  Excel format with pH grouping and catalyst metadata

* **Case 04**
  Excel format with block-structured datasets

#### Usage

```matlab
Universal_Waveguide_Fit()              % Interactive file selection
Universal_Waveguide_Fit(filePath)     % Specify input file explicitly
```

#### Outputs

* Optimized parameters saved as **text files**
* Figures saved as **PNG** and **FIG**
* Analysis results saved as **MAT files**
  (directly usable by `Figure02.m`)

---

## Requirements

* MATLAB **R2019b+** (R2020b+ recommended)

  * Mainly for `tiledlayout`
* No special toolboxes are required for plotting
* `Figure02.m` requires `.mat` files containing a variable named `OUT` (see below)

---

## Quick Start

### 1) Generate Figure 01

**Conceptual two-mode waveguide kinetics**

```matlab
Figure01
```

This produces:

* `Figure01.png` (600 dpi)

> To modify mode strengths, asymmetry parameters (\xi), growth rates (\lambda), or the range of (\tilde{\eta}), edit the `cfg` structure at the top of `Figure01.m`.

---

### 2) Run universal waveguide fitting on experimental data

```matlab
Universal_Waveguide_Fit
```

or

```matlab
Universal_Waveguide_Fit('your_data_file.xlsx')
```

This generates:

* Fitted figures
* Parameter text files
* MAT files compatible with `Figure02.m`

---

### 3) Assemble the summary figure (Figure 02)

By default, `Figure02.m` expects **exactly four** MAT files:

```matlab
Figure02
```

Default filenames:

* `Figure_data01.mat`
* `Figure_data02.mat`
* `Figure_data03.mat`
* `Figure_data04.mat`

Custom usage:

```matlab
matFiles = {
    'Figure_data01.mat'
    'Figure_data02.mat'
    'Figure_data03.mat'
    'Figure_data04.mat'
};
Figure02(matFiles, 'Figure02.png');
```

---

## Expected MAT structure for `Figure02.m`

Each MAT file must contain a variable named `OUT`.

### Required fields

#### `OUT.RES` — raw data

Array of structs, one per group:

* `OUT.RES(g).eta`
  Raw overpotential (V)

* `OUT.RES(g).j`
  Raw current density (e.g. mA cm(^{-2}))

---

#### `OUT.D` — processed and fitted results

Cell array (or convertible struct array), one cell per group.

Commonly used fields:

* `OUT.D{g}.etaFine`
  Fine potential grid (V)

* `OUT.D{g}.jFit`
  Stored fitted curve on `etaFine`

* `OUT.D{g}.eta_t`
  Dimensionless overpotential (\tilde{\eta})

* `OUT.D{g}.Pi_dens_t`
  Power-flow density (\Pi_{\mathrm{dens}}(\tilde{\eta}))

* `OUT.D{g}.etaStar_t` *(optional but recommended)*
  Optimal (\tilde{\eta}^*)

* `OUT.D{g}.PiStar_t` *(optional but recommended)*
  Optimal (\Pi_{\mathrm{dens}}^*)

---

## Output and Resolution

All figures are exported as **high-resolution PNG files** using:

* `-r600` (600 dpi)

Files are saved in the current working directory unless the output path is modified.

---

## Citation

If you use this code in academic work, please cite:

1. **H. Cai, B. Chen**,
   *A universal waveguide mass–energy relation for lossy one-dimensional waves in nature*,
   arXiv (2026). [https://doi.org/10.48550/arXiv.2602.04171](https://doi.org/10.48550/arXiv.2602.04171)

2. **B. Chen, H. Cai**,
   *A waveguide kinetics framework for electrochemical polarization*,
   arXiv (2026). [http://arxiv.org/abs/2602.05455](http://arxiv.org/abs/2602.05455)

---

## License

**Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)**

---

## Contact

For questions, issues, or reproducibility requests:

* Open a **GitHub Issue** in this repository
* or contact: **[caihy7@mail.sysu.edu.cn](mailto:caihy7@mail.sysu.edu.cn)**

---
