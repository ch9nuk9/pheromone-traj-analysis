# Codebase Assessment: Pheromone Trajectory Analysis

## Overview

This MATLAB codebase (targeting R2023b) analyzes **C. elegans (nematode worm) locomotion trajectories** in response to **pheromone stimulation**. The research studies how worms navigate toward pheromone sources, comparing males vs. hermaphrodites across different genetic strains (PS8023, PS9470, PS9478 -- all him-5 mutants). The code supports figure generation for an associated research paper.

**License:** CC BY-NC-SA 4.0

---

## Repository Structure

```
.
├── prpr_traj_newdata0128.m          # Main trajectory preprocessing pipeline
├── readme.txt                       # Usage instructions
├── Fig3/                            # Velocity time-series & bar plot figures
│   ├── preprocess_exceldata.m       # Excel data preprocessing (6 strain/sex combos)
│   ├── fig3redbarplots.m            # Bar plots with Fourier analysis
│   ├── visualize_figure3_20240617.m # Individual trajectory + velocity plots
│   ├── fillgap.m                    # Linear interpolation for missing data
│   ├── fourier_analysis_rab3.m      # FFT of velocity time-series
│   ├── plot_areaerrorbar.m          # Mean ± error shaded area plot (3rd party)
│   └── trimtrailingzeros.m          # Remove trailing zero-padded data
├── Fig5BC/                          # Sprint behavior analysis
│   ├── F5B.m                        # Calcium imaging signal visualization
│   └── sprint0422_newdata.m         # Sprint velocity vs. distance-to-target
└── Fig6/                            # Turn dynamics & velocity statistics
    ├── commonshape_dc.m             # Typical taxis-turn shape (aligned/rescaled)
    ├── signature_taxisturns.m       # Taxis turn extraction from cross-corr data
    ├── timelag_him5newdata.m        # Time-lag cross-correlation (Dq vs. direction)
    └── velocitystatistics0716.m     # Velocity magnitude distributions & quadrant analysis
```

---

## Detailed File-by-File Functionality

### 1. `prpr_traj_newdata0128.m` — Main Preprocessing Pipeline

**Purpose:** Loads raw trajectory data from Excel, computes kinematic quantities, and saves processed `.mat` files.

**Key operations:**
- Reads X/Y coordinate time-series from `.xlsx` files (paired columns per worm)
- Extracts metadata: stimulation frame, target-finding frame, trajectory IDs
- Cleans data: removes trailing zeros (`trimtrailingzeros`), fills gaps via linear interpolation (`fillgap`), filters bad indices
- **Target position estimation:** For each experimental set, estimates the pheromone source location by:
  - Collecting endpoint positions of worms that found the target
  - Fitting a circle through 3+ points (median of all 3-point circumscribed circles)
  - Falling back to median position if radius > 6 units
- **Savitzky-Golay smoothing** (order 3, frame 95) on X/Y coordinates
- **Velocity computation:** `v = ds/dt` with moving-mean smoothing (window=40 frames)
- **Direction correctness:** `cos(theta)` between velocity vector and direction-to-target
- **Rotational diffusivity (Dq):** Angular change squared per unit time, measuring turning rate
- **Distance to target:** Euclidean distance with moving-mean smoothing
- **Radial velocity (dr/dt):** Rate of approach/retreat from target

**Local functions:**
- `get_center_3points(x,y)` — Circumscribed circle center from 3 points
- `get_center(x,y)` — Robust center estimate via median of all 3-point combinations
- `is_empty_data(xx)` — Checks for all-zero columns

**Parameters:**
- `dt_sec = 0.1333` (7.5 fps), `Nframe = 40`, `offset = 40`, `polyorder = 3`, `framesize = 95`
- `Nsets = 23` experimental sets, `Ndata` = number of individual trajectories

---

### 2. `Fig3/preprocess_exceldata.m` — Strain-specific Preprocessing

**Purpose:** Processes trajectory data for 6 strain/sex combinations and generates velocity-over-time plots with stimulation period overlays.

**Key operations:**
- Iterates over 6 datasets (3 strains x 2 sexes: PS9478, PS9470, PS8023 for male/hermaphrodite)
- Applies correction factor `25/4.4` (pixel-to-micron conversion)
- Computes velocity using finite differences over `Nframe=40` frame windows
- Normalizes each trajectory's velocity by its maximum
- Computes MSD (mean squared displacement) from final position and radial velocity
- Plots velocity time-series with red-shaded stimulation periods using `plot_areaerrorbar`
- Saves processed data as `.mat` files

---

### 3. `Fig3/fig3redbarplots.m` — Velocity + Fourier Bar Plots

**Purpose:** Same preprocessing as above but for PS9478 strain only, with added Fourier analysis.

**Key addition over `preprocess_exceldata.m`:**
- Calls `fourier_analysis` (likely `fourier_analysis_rab3.m`) after velocity plotting
- Exports frequency-domain plots showing spectral content of velocity signals

---

### 4. `Fig3/visualize_figure3_20240617.m` — Individual Trajectory Visualization

**Purpose:** Generates publication-quality trajectory and velocity plots for 4 representative worms.

**Key operations:**
- Loads preprocessed `.mat` files for 4 datasets
- Plots specific trajectory IDs {2, 10, 9, 14} as color-coded scatter plots (color = time)
- Generates separate velocity-vs-time line plots
- Coordinates are converted to mm (÷1000)

---

### 5. `Fig3/fillgap.m` — Gap Interpolation Utility

**Purpose:** Linearly interpolates zero-valued gaps in X/Y coordinate data.

**Algorithm:** Finds contiguous runs of zeros, replaces with linear interpolation between boundary values.

---

### 6. `Fig3/fourier_analysis_rab3.m` — FFT Analysis

**Purpose:** Computes single-sided amplitude spectrum of normalized velocity data.

**Key operations:**
- FFT of velocity matrix (mean-subtracted)
- Plots amplitude spectrum with `plot_areaerrorbar` (mean ± std across worms)
- Frequency range limited to 0-0.4 Hz

---

### 7. `Fig3/plot_areaerrorbar.m` — Shaded Error Band Plotting (3rd Party)

**Purpose:** Plots mean with shaded error bands (std, sem, var, or 95% CI).

**Author:** Victor Martinez-Cagigal (2018)

---

### 8. `Fig3/trimtrailingzeros.m` — Trailing Zero Removal

**Purpose:** Truncates time-series at the last non-zero X value.

---

### 9. `Fig5BC/F5B.m` — Calcium Imaging Signal Visualization

**Purpose:** Plots calcium imaging (GCaMP6s) fluorescence signals (DeltaR/R0) with stimulation period overlays.

**Key operations:**
- Reads from Excel files named `prog{1,2,3}{DA,M9,SP_1_10_100,SP_500_1000_2000}.xlsx`
- Computes mean ± SEM across replicates
- Overlays colored rectangles for 3 stimulation periods at [0,2], [4,6], [8,10] minutes
- Uses two color schemes (green/red gradients) for head vs. tail neuron regions
- 3 programs x 4 conditions = 12 plots total

---

### 10. `Fig5BC/sprint0422_newdata.m` — Sprint Behavior Analysis

**Purpose:** Analyzes velocity as a function of distance-to-target (post-stimulation "sprinting" behavior).

**Key operations:**
- Separates data into pre-stimulation (by time) and post-stimulation (by distance) periods
- Filters for straight-running segments only (`Dq < 0.15`)
- Normalizes velocity by pre-stimulation mean
- Bins and smooths data using `rloess` smoother
- Identifies "sprint zone" at distance < 3.2 mm from target (highlighted with darker shading)
- Produces two figures: velocity vs. time (pre-stim) and velocity vs. distance (post-stim, reversed x-axis)

---

### 11. `Fig6/signature_taxisturns.m` — Taxis Turn Extraction

**Purpose:** Extracts and catalogs individual taxis-turn events from trajectory data.

**Key operations:**
- Reads turn time ranges from `quicksteering.xlsx` (manually annotated)
- For each annotated turn, extracts direction-correctness (dc) and turning rate (Dq) sub-series
- Identifies turn onset by finding transitions in direction correctness sign
- Collects all turn events into `dc_all` and `Dq_all` cell arrays

---

### 12. `Fig6/commonshape_dc.m` — Typical Taxis Turn Shape

**Purpose:** Computes and visualizes the "average shape" of taxis turns by time-rescaling and alignment.

**Key operations:**
- Aligns all extracted turns by their peak (minimum of dc) position
- Rescales time axis so peaks coincide at the median peak fraction
- Normalizes dc by its minimum and Dq by its maximum
- Interpolates all turns onto a common time grid
- Plots median ± std of both normalized dc and Dq on dual y-axes
- Produces the canonical "taxis turn signature" figure

---

### 13. `Fig6/timelag_him5newdata.m` — Time-Lag Cross-Correlation

**Purpose:** Computes windowed cross-correlation between direction-correctness and turning rate (Dq) across the search trajectory.

**Key operations:**
- Loads preprocessed data with group assignments
- For each worm in each group, extracts dc and Dq over the stimulation-to-target-found interval
- Calls a `timelag()` function (not included in repo) to compute windowed cross-correlation
- Visualizes as a surface plot (heatmap): x = time, y = worm#, color = cross-correlation strength
- Uses `bluewhitered` colormap (not included in repo)

---

### 14. `Fig6/velocitystatistics0716.m` — Velocity Distribution Analysis

**Purpose:** Comprehensive velocity statistics comparing successful vs. unsuccessful target-finders.

**Two analysis modes:**

**Mode "vmag":**
- Separates velocity distributions into 4 categories: before/after stimulation x found/not-found target
- Filters for straight-running segments (`Dq < threshold`)
- Plots 2x2 histogram grid with mean annotations

**Mode "dot" (quadrant analysis):**
- Plots radial velocity (V_R = dr/dt) vs. tangential velocity (V_T = |v|) after stimulation
- Divides into 4 quadrants based on mean velocity and dr/dt sign
- Reports percentage of data points in each quadrant for found vs. not-found worms
- This reveals whether successful worms show stronger directional bias

---

## Data Flow

```
Raw Excel data (.xlsx with X/Y coordinates)
        │
        ▼
prpr_traj_newdata0128.m  OR  Fig3/preprocess_exceldata.m
        │
        ▼
Processed .mat files (trajectories, velocities, Dq, dc, distances)
        │
        ├──► Fig3/fig3redbarplots.m ──► velocity + frequency plots
        ├──► Fig3/visualize_figure3_20240617.m ──► trajectory + velocity panels
        ├──► Fig5BC/sprint0422_newdata.m ──► sprint behavior figures
        ├──► Fig6/velocitystatistics0716.m ──► velocity distribution figures
        ├──► Fig6/signature_taxisturns.m ──► extracted turn events
        │         │
        │         ▼
        │    Fig6/commonshape_dc.m ──► canonical turn shape figure
        └──► Fig6/timelag_him5newdata.m ──► cross-correlation heatmaps
```

---

## Key Computed Quantities

| Quantity | Symbol | Description |
|----------|--------|-------------|
| Velocity magnitude | `v` | Smoothed speed (moving mean, window=40 frames) |
| Direction correctness | `dc` | cos(angle between velocity and target direction) |
| Rotational diffusivity | `Dq` | Angular change² per unit time (turning rate proxy) |
| Radial velocity | `dr/dt` | Rate of change of distance to target |
| Distance to target | `d` | Smoothed Euclidean distance to estimated target |
| Search duration | - | Time from stimulation to target-finding |

---

## Dependencies & External Requirements

### MATLAB Built-in Functions Used
- `readmatrix`, `readcell`, `xlsread` — Excel I/O
- `sgolayfilt` — Savitzky-Golay smoothing
- `movmean` — Moving average
- `fft` — Fast Fourier Transform
- `interp1` — 1D interpolation
- `histcounts`, `accumarray` — Binning/aggregation
- `smooth` — Curve fitting toolbox (rloess smoother)
- `nchoosek` — Combinatorics
- `exportgraphics`, `saveas` — Figure export

### Missing Dependencies (not in repo)
- **`timelag()` function** — Called in `timelag_him5newdata.m:74` but not provided
- **`bluewhitered` colormap** — Called in `timelag_him5newdata.m:110` but not provided (commonly available on MATLAB File Exchange)
- **`fourier_analysis` script** — Called in `fig3redbarplots.m:116` (likely meant to be `fourier_analysis_rab3` but the call uses a different name)
- **Input data files** — All `.xlsx` source data files are absent from the repository

### MATLAB Toolboxes Required
- **Signal Processing Toolbox** — for `sgolayfilt`
- **Curve Fitting Toolbox** — for `smooth` with `rloess` method
- **Statistics and Machine Learning Toolbox** — for `quantile`

---

## Code Quality Observations

### Strengths
1. **Modular utility functions** — `fillgap`, `trimtrailingzeros`, `plot_areaerrorbar` are reusable
2. **Comprehensive kinematic analysis** — Covers velocity, directionality, turning rate, and distance metrics
3. **Robust target estimation** — Uses median-of-circumscribed-circles approach with fallbacks

### Issues and Risks

1. **Hardcoded parameters throughout** — `bad_inds`, `Nsets=23`, `offset=40`, `framesize=95`, specific trajectory IDs `{2,10,9,14}` are all hardcoded. Any new dataset requires manual code edits.

2. **Duplicated preprocessing logic** — `preprocess_exceldata.m` and `fig3redbarplots.m` contain nearly identical data loading and velocity computation code (lines 15-71 are ~95% identical). This violates DRY and risks divergent behavior.

3. **Missing function: `timelag()`** — `timelag_him5newdata.m` calls `timelag()` at line 74, which is not provided in the repository. This makes Fig6 time-lag analysis non-reproducible.

4. **Missing colormap: `bluewhitered`** — Required by `timelag_him5newdata.m` but not included.

5. **Function name mismatch** — `fig3redbarplots.m:116` calls `fourier_analysis` but the actual file is named `fourier_analysis_rab3.m`. This will error unless there's an unlisted `fourier_analysis.m` or the function was renamed.

6. **Potential index-out-of-bounds** — In `prpr_traj_newdata0128.m:276`, `stim_frame_range = stim_frame-50:stim_frame+20` is used to index `tmpv`, but there's no bounds check. If `stim_frame < 51` or `stim_frame + 21 > length(tmpv)`, this will crash.

7. **Comparison of char with string** — `prpr_traj_newdata0128.m:122` uses `target_frame=='N'` which compares a cell value with a character. This works for character arrays but will silently fail for string objects.

8. **Growing arrays in loops** — Multiple instances of `bad_inds = [bad_inds, ii]` and similar patterns (`v_before`, `v_after`, etc.) grow arrays incrementally, which is inefficient in MATLAB.

9. **No input validation** — Functions like `fillgap` will crash if a gap extends to the first or last element (index `jlow-1` or `jhigh+1` out of bounds).

10. **Workspace pollution** — Scripts use `save(dataname)` without specifying variables, saving the entire workspace. This creates large `.mat` files with transient variables.

11. **Dead/commented code** — Multiple files contain commented-out code blocks, unused variables, and debug `disp` statements (e.g., `prpr_traj_newdata0128.m:109` prints `ii` on every iteration).

12. **No data files in repo** — The repository contains only code; all input `.xlsx` files are absent, making independent reproduction impossible without the original data.

13. **Inconsistent variable naming** — Mixed conventions: `bad_inds` vs `good_inds`, `tmpprefix` vs `prefix`, `xx` vs `x_smooth`, `mylw` vs `LW`.

14. **`velocitystatistics0716.m:173`** references undefined variable `dr` — likely a leftover debug statement that will cause a runtime error.

---

## Summary

This is a **research-grade analysis codebase** for a neurobiology paper studying C. elegans chemotaxis behavior. It implements a complete pipeline from raw tracking data to publication figures, covering trajectory preprocessing, kinematic feature extraction, spectral analysis, sprint detection, turn characterization, and statistical comparison of successful vs. unsuccessful target-finding behaviors.

The code is functional for its intended one-time analysis purpose but has typical academic code limitations: hardcoded parameters, code duplication, missing dependencies, and no automated testing. Reproducing the full analysis requires the missing input data files, the `timelag()` function, and the `bluewhitered` colormap.
