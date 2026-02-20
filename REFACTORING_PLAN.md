# MATLAB → Python Refactoring Plan
## C. elegans Pheromone Trajectory Analysis

---

## 1. Agent Hierarchy

```
┌─────────────────────────────────────────────┐
│           ORCHESTRATOR AGENT                │
│  Integrates all domain outputs, resolves    │
│  conflicts, maintains coherent architecture │
└──────────┬──────────┬──────────┬────────────┘
           │          │          │
     ┌─────▼──┐  ┌───▼────┐  ┌─▼──────────┐
     │ MATH / │  │ BIOLOGY│  │ OPERATIONS │
     │ STATS  │  │ NEURO  │  │ EXPANSION  │
     │ EXPERT │  │ EXPERT │  │ EXPERT     │
     └────────┘  └────────┘  └────────────┘
           │          │          │
           └──────────┼──────────┘
                      │
              ┌───────▼───────┐
              │   QA AGENT    │
              │ Correctness & │
              │  Coherence    │
              └───────────────┘
```

---

## 2. Target Python Package Structure

```
pheromone_traj_analysis/
├── pyproject.toml
├── requirements.txt
├── src/
│   └── pheromone_analysis/
│       ├── __init__.py
│       ├── config.py                    # All constants & parameters (centralized)
│       │
│       ├── io/
│       │   ├── __init__.py
│       │   └── data_loader.py           # Excel → pandas, .mat ↔ HDF5/pickle
│       │
│       ├── preprocessing/
│       │   ├── __init__.py
│       │   ├── gap_filling.py           # fillgap.m → linear interpolation
│       │   ├── zero_trimming.py         # trimtrailingzeros.m
│       │   ├── smoothing.py             # Savitzky-Golay, moving mean wrappers
│       │   └── target_estimation.py     # Circumscribed circle fitting (3-point, N-point median)
│       │
│       ├── kinematics/
│       │   ├── __init__.py
│       │   ├── velocity.py              # Speed computation, radial velocity (dr/dt)
│       │   ├── direction.py             # Direction correctness cos(θ), angular diffusivity Dq
│       │   └── distance.py              # Euclidean distance to target
│       │
│       ├── analysis/
│       │   ├── __init__.py
│       │   ├── spectral.py              # FFT / single-sided amplitude spectrum
│       │   ├── sprint_detection.py      # Sprint zone identification (Dq < 0.15, dist < 3.2mm)
│       │   ├── taxis_turns.py           # Turn extraction & canonical shape (alignment + rescaling)
│       │   ├── cross_correlation.py     # Windowed time-lag cross-correlation (dc vs Dq)
│       │   └── velocity_statistics.py   # Distribution analysis, quadrant analysis (VR vs VT)
│       │
│       ├── visualization/
│       │   ├── __init__.py
│       │   ├── error_bands.py           # plot_areaerrorbar.m → shaded mean±error
│       │   ├── figure3.py               # Velocity time-series, bar plots, trajectory scatter
│       │   ├── figure5.py               # Calcium imaging + sprint behavior plots
│       │   └── figure6.py               # Taxis turn shape, cross-correlation heatmaps, vel stats
│       │
│       └── pipeline.py                  # End-to-end orchestration: preprocessing → analysis → figures
│
├── tests/
│   ├── __init__.py
│   ├── test_preprocessing.py
│   ├── test_kinematics.py
│   ├── test_analysis.py
│   └── test_visualization.py
│
└── scripts/
    ├── run_preprocessing.py             # Replaces prpr_traj_newdata0128.m
    ├── run_figure3.py                   # Replaces Fig3/*.m
    ├── run_figure5.py                   # Replaces Fig5BC/*.m
    └── run_figure6.py                   # Replaces Fig6/*.m
```

---

## 3. MATLAB → Python Function Identity Map

### 3.1 Source File Mapping

| MATLAB File | Python Module | Justification |
|---|---|---|
| `prpr_traj_newdata0128.m` | `pipeline.py`, `io/data_loader.py`, `preprocessing/*`, `kinematics/*` | Monolithic script → decomposed into IO, preprocessing, and kinematics modules |
| `Fig3/preprocess_exceldata.m` | `io/data_loader.py`, `visualization/figure3.py` | Data loading separated from plotting; eliminates duplication with `fig3redbarplots.m` |
| `Fig3/fig3redbarplots.m` | `visualization/figure3.py`, `analysis/spectral.py` | Plotting + Fourier analysis separated; duplicate preprocessing eliminated |
| `Fig3/visualize_figure3_20240617.m` | `visualization/figure3.py` | Publication figure generation |
| `Fig3/fillgap.m` | `preprocessing/gap_filling.py` | Standalone utility → proper module |
| `Fig3/trimtrailingzeros.m` | `preprocessing/zero_trimming.py` | Standalone utility → proper module |
| `Fig3/fourier_analysis_rab3.m` | `analysis/spectral.py` | FFT analysis isolated as reusable function |
| `Fig3/plot_areaerrorbar.m` | `visualization/error_bands.py` | 3rd-party plotting utility → clean Python wrapper around matplotlib fill_between |
| `Fig5BC/F5B.m` | `visualization/figure5.py` | Calcium imaging visualization |
| `Fig5BC/sprint0422_newdata.m` | `analysis/sprint_detection.py`, `visualization/figure5.py` | Analysis logic separated from plotting |
| `Fig6/commonshape_dc.m` | `analysis/taxis_turns.py`, `visualization/figure6.py` | Turn shape computation separated from visualization |
| `Fig6/signature_taxisturns.m` | `analysis/taxis_turns.py` | Turn extraction logic |
| `Fig6/timelag_him5newdata.m` | `analysis/cross_correlation.py`, `visualization/figure6.py` | Cross-correlation computation separated from heatmap plotting |
| `Fig6/velocitystatistics0716.m` | `analysis/velocity_statistics.py`, `visualization/figure6.py` | Statistical analysis separated from histogram/quadrant plotting |

### 3.2 Function Identity Map

| MATLAB Function/Operation | Python Function | Module | Justification |
|---|---|---|---|
| `fillgap(x, y)` | `fill_gaps(x: np.ndarray, y: np.ndarray) → tuple[np.ndarray, np.ndarray]` | `preprocessing/gap_filling.py` | Replaces zero-valued gaps with `np.interp`; adds bounds checking missing in original |
| `trimtrailingzeros(x, y)` | `trim_trailing_zeros(x: np.ndarray, y: np.ndarray) → tuple[np.ndarray, np.ndarray]` | `preprocessing/zero_trimming.py` | Finds last nonzero x index, truncates both arrays |
| `sgolayfilt(data, order, framesize)` | `savgol_smooth(data, polyorder=3, window=95)` | `preprocessing/smoothing.py` | Wraps `scipy.signal.savgol_filter`; same algorithm, validated numerically |
| `movmean(data, window)` | `moving_mean(data, window)` | `preprocessing/smoothing.py` | Wraps `np.convolve` or `pd.Series.rolling().mean()` |
| `get_center_3points(x, y)` | `circumscribed_center_3pts(x, y)` | `preprocessing/target_estimation.py` | Solves 2×2 linear system for circumscribed circle center from 3 points |
| `get_center(x, y)` | `estimate_target_position(x, y, radius_threshold=6.0)` | `preprocessing/target_estimation.py` | Median of all `C(n,3)` circumscribed centers; falls back to coordinate median if radius > threshold |
| `is_empty_data(xx)` | `is_empty_trajectory(data)` | `io/data_loader.py` | Checks if column is all zeros |
| Velocity: `ds/dt` | `compute_velocity(x, y, dt, n_frames=40)` | `kinematics/velocity.py` | `v = sqrt(dx²+dy²) / (N*dt)` over sliding window |
| Direction correctness: `cos(θ)` | `direction_correctness(vx, vy, target_x, target_y, pos_x, pos_y)` | `kinematics/direction.py` | `cos(θ) = (v⃗ · d⃗) / (|v⃗||d⃗|)` where d⃗ = target - position |
| Rotational diffusivity Dq | `angular_diffusivity(theta, offset)` | `kinematics/direction.py` | `Dq = |Δθ|² / (2·offset·dt)` — mean-squared angular change rate |
| Radial velocity dr/dt | `radial_velocity(distance, dt)` | `kinematics/velocity.py` | `dr/dt = Δdist / Δt` — smoothed rate of distance change |
| Distance to target | `distance_to_target(x, y, target)` | `kinematics/distance.py` | Euclidean distance with optional moving-mean smoothing |
| `fft(vel - mean(vel))` | `velocity_fft(velocity_matrix, fs=7.5)` | `analysis/spectral.py` | `np.fft.fft` on mean-subtracted signal; returns single-sided amplitude spectrum |
| Sprint detection | `detect_sprints(velocity, dq, distance, dq_thresh=0.15, sprint_dist=3.2)` | `analysis/sprint_detection.py` | Filters for straight segments (Dq < thresh), bins by distance, applies LOESS smoothing |
| `smooth(x, y, span, 'rloess')` | `rloess_smooth(x, y, span=0.1)` | `analysis/sprint_detection.py` | `statsmodels.nonparametric.lowess` with robustifying iterations |
| Turn extraction | `extract_taxis_turns(dc, dq, turn_ranges)` | `analysis/taxis_turns.py` | Reads annotated turn time ranges, extracts dc/Dq sub-series, finds onset by sign change |
| Canonical turn shape | `compute_canonical_turn_shape(dc_all, dq_all, n_points=100)` | `analysis/taxis_turns.py` | Peak-aligned, time-rescaled, amplitude-normalized; `np.interp` onto common grid |
| `timelag()` (missing) | `windowed_cross_correlation(signal_a, signal_b, window_size, max_lag)` | `analysis/cross_correlation.py` | **Reimplemented**: sliding-window normalized cross-correlation using `np.correlate` |
| `bluewhitered` (missing) | Uses `matplotlib.colors.TwoSlopeNorm` + `RdBu_r` | `visualization/figure6.py` | Standard diverging colormap; equivalent to MATLAB File Exchange version |
| `histcounts` + `accumarray` | `bin_and_aggregate(values, bins, agg_func)` | `analysis/velocity_statistics.py` | `np.digitize` + grouped aggregation via pandas or manual |
| `plot_areaerrorbar` | `plot_shaded_error(ax, x, y_mean, y_error, ...)` | `visualization/error_bands.py` | `ax.fill_between()` with configurable error type (std, sem, ci95) |
| Quadrant analysis | `quadrant_analysis(vr, vt, vr_threshold=0, vt_threshold)` | `analysis/velocity_statistics.py` | Computes percentages in 4 quadrants of VR-vs-VT space |

### 3.3 MATLAB Built-in → Python Library Map

| MATLAB | Python | Package |
|---|---|---|
| `readmatrix`, `readcell`, `xlsread` | `pd.read_excel()` | pandas + openpyxl |
| `sgolayfilt` | `scipy.signal.savgol_filter` | scipy |
| `movmean` | `pd.Series.rolling().mean()` or `np.convolve` | pandas/numpy |
| `fft` | `np.fft.fft` | numpy |
| `interp1` | `np.interp` | numpy |
| `nchoosek` | `itertools.combinations` | stdlib |
| `histcounts` | `np.histogram` / `np.digitize` | numpy |
| `accumarray` | `pd.DataFrame.groupby().agg()` | pandas |
| `smooth(..., 'rloess')` | `statsmodels.nonparametric.lowess` | statsmodels |
| `exportgraphics` | `fig.savefig()` | matplotlib |
| `save / load (.mat)` | `pickle.dump/load` or `h5py` | stdlib/h5py |

---

## 4. Centralized Configuration (`config.py`)

```python
"""All hardcoded parameters extracted and centralized."""
from dataclasses import dataclass

@dataclass(frozen=True)
class AcquisitionParams:
    fps: float = 7.5                    # Frames per second
    dt_sec: float = 1 / 7.5             # ≈ 0.1333 s/frame
    pixel_to_um: float = 25 / 4.4       # Pixel-to-micron conversion factor

@dataclass(frozen=True)
class SmoothingParams:
    savgol_polyorder: int = 3           # Savitzky-Golay polynomial order
    savgol_window: int = 95             # Savitzky-Golay frame size (must be odd)
    moving_mean_window: int = 40        # Moving average window (frames)
    velocity_offset: int = 40           # Offset for velocity finite differences

@dataclass(frozen=True)
class AnalysisParams:
    dq_straight_threshold: float = 0.15 # Dq threshold for "straight running"
    sprint_distance_mm: float = 3.2     # Distance threshold for sprint zone
    target_radius_threshold: float = 6.0 # Max radius for circumscribed circle fallback
    rloess_span: float = 0.1            # LOESS smoothing span
    fft_freq_max: float = 0.4           # Maximum frequency for FFT plots (Hz)

@dataclass(frozen=True)
class ExperimentalDesign:
    n_sets: int = 23                    # Number of experimental sets
    strains: tuple = ("PS9478", "PS9470", "PS8023")
    sexes: tuple = ("male", "hermaphrodite")
    stim_periods_min: tuple = ((0, 2), (4, 6), (8, 10))  # Stimulation windows (minutes)
```

---

## 5. Agent Responsibilities — Detailed

### 5.1 Agent 1: Math & Statistics Expert

**Scope**: Numerical correctness of all algorithms

**Files owned**:
- `preprocessing/smoothing.py` — Validate SG filter parameters (order 3, window 95) produce equivalent output to MATLAB `sgolayfilt`
- `preprocessing/target_estimation.py` — Verify circumscribed circle linear algebra: the 2×2 system `[2(x1-x3), 2(y1-y3); 2(x2-x3), 2(y2-y3)] * [cx;cy] = [x1²+y1²-x3²-y3²; x2²+y2²-x3²-y3²]`
- `kinematics/velocity.py` — Confirm velocity formula: `v_i = sqrt((x_{i+N}-x_i)² + (y_{i+N}-y_i)²) / (N·dt)`
- `kinematics/direction.py` — Validate Dq formula: `Dq = (Δθ)² / (2·Δt)` with proper angle wrapping
- `analysis/spectral.py` — FFT: single-sided spectrum `P1 = 2*abs(Y(1:N/2+1))/N`, frequency axis `f = fs*(0:N/2)/N`
- `analysis/cross_correlation.py` — Implement `timelag()` (missing from MATLAB repo): windowed normalized cross-correlation `r(τ) = Σ(a·b) / sqrt(Σa²·Σb²)`
- `analysis/sprint_detection.py` — Validate LOESS smoothing equivalence to MATLAB `smooth(...,'rloess')`

**Validation criteria**:
- Unit tests with known-answer inputs for each formula
- Numerical tolerance checks (MATLAB vs Python output within `rtol=1e-10`)

### 5.2 Agent 2: Biology & Neuroscience Expert

**Scope**: Biological correctness and domain-appropriate interpretation

**Files owned**:
- `kinematics/direction.py` — Validate direction correctness semantics: `cos(θ) > 0` means moving toward target (chemotaxis), `cos(θ) < 0` means moving away. Verify the vector math computes `angle(velocity, target_direction)` not `angle(velocity, position)`
- `analysis/taxis_turns.py` — Validate turn extraction: a "taxis turn" is a reorientation event where the worm transitions from moving away (dc < 0) to moving toward (dc > 0) the pheromone source. The onset is the last dc > 0 before the negative excursion. Peak is the minimum dc (maximum misalignment). Verify biological plausibility of alignment + rescaling
- `analysis/sprint_detection.py` — Validate that Dq < 0.15 correctly identifies straight-running (low angular diffusivity) segments. Sprint zone at < 3.2mm corresponds to near-target approach behavior
- `analysis/velocity_statistics.py` — Validate quadrant analysis interpretation: Q1 (fast approach) vs Q4 (fast retreat) distinguish successful chemotaxis. Confirm that `found` vs `not_found` grouping correctly tests the hypothesis
- `visualization/figure5.py` — Validate calcium imaging: ΔR/R₀ signal processing, stimulation period overlay timing (0-2, 4-6, 8-10 min), head vs tail neuron region color coding
- `config.py` — Verify all biological constants: 7.5 fps matches typical C. elegans tracking, 25/4.4 pixel-to-µm is appropriate for the imaging setup

**Validation criteria**:
- Docstrings include biological context (what each quantity means for worm behavior)
- Parameter names use domain terminology (chemotaxis, taxis turn, angular diffusivity)
- Assertions on biologically impossible values (negative distances, speeds > physiological max)

### 5.3 Agent 3: Operations Expansion Expert

**Scope**: Software architecture, code quality, and extensibility

**Files owned**:
- `pyproject.toml` + `requirements.txt` — Package setup with pinned dependencies
- `config.py` — Dataclass-based configuration with validation
- `io/data_loader.py` — Pandas-based Excel loading, trajectory metadata extraction, `.mat` replacement with pickle/HDF5
- `pipeline.py` — End-to-end orchestrator replacing `prpr_traj_newdata0128.m`: loads → cleans → smooths → computes kinematics → saves
- `preprocessing/gap_filling.py` + `zero_trimming.py` — Utility modules with input validation (fixing the boundary bugs in original)
- `visualization/error_bands.py` — Clean matplotlib wrapper replacing the 3rd-party `plot_areaerrorbar.m`
- All `__init__.py` files — Public API surface
- All `scripts/*.py` — CLI entry points
- All `tests/*.py` — Test scaffolding

**Validation criteria**:
- No circular imports
- All modules importable independently
- Type hints on all public functions
- Consistent error handling (custom exceptions, not bare asserts)

---

## 6. Execution Order

```
Phase 1: OPERATIONS EXPANSION (scaffolding)
  → Creates package structure, config.py, io/, preprocessing utilities
  → Establishes the skeleton that other agents fill

Phase 2: MATH/STATS + BIOLOGY/NEURO (parallel, independent modules)
  → Math agent: kinematics/*, analysis/spectral.py, analysis/cross_correlation.py,
                 analysis/sprint_detection.py
  → Bio agent:  analysis/taxis_turns.py, analysis/velocity_statistics.py,
                 visualization/*.py (with domain-correct docstrings)

Phase 3: ORCHESTRATOR INTEGRATION
  → Wires pipeline.py connecting all modules
  → Resolves any interface conflicts between agents
  → Creates script entry points

Phase 4: QA AGENT
  → Function-by-function cross-reference: every MATLAB operation has a Python equivalent
  → No functionality lost (checklist of all 14 source files)
  → Edge case review (boundary conditions, empty data, zero-length trajectories)
  → Static analysis (type checking, import validation)
  → Data flow integrity (Excel → processed → figures produces same pipeline)
```

---

## 7. Known Issues to Fix During Refactoring

| # | Original Bug | Fix in Python |
|---|---|---|
| 1 | `stim_frame-50` can be negative (no bounds check) | Clamp to `max(0, stim_frame - 50)` |
| 2 | `fillgap` crashes if gap at array boundary | Add boundary guards in `fill_gaps()` |
| 3 | `target_frame=='N'` char/string comparison fragile | Use `pd.isna()` or explicit `None` check |
| 4 | `save(dataname)` saves entire workspace | `pickle.dump()` with explicit variable dict |
| 5 | `fig3redbarplots.m` calls `fourier_analysis` (wrong name) | Single `velocity_fft()` function, no ambiguity |
| 6 | `velocitystatistics0716.m:173` references undefined `dr` | Proper scoping eliminates stale variables |
| 7 | `timelag()` function missing | Reimplemented as `windowed_cross_correlation()` |
| 8 | `bluewhitered` colormap missing | Use `matplotlib` diverging colormap + `TwoSlopeNorm` |
| 9 | Growing arrays in loops (`bad_inds = [bad_inds, ii]`) | Pre-allocate or use list append + single conversion |
| 10 | Duplicated preprocessing in `preprocess_exceldata.m` / `fig3redbarplots.m` | Single `load_and_preprocess()` function |

---

## 8. Dependencies

```
numpy>=1.24
scipy>=1.10
pandas>=2.0
matplotlib>=3.7
openpyxl>=3.1
statsmodels>=0.14
h5py>=3.8
pytest>=7.0
```

---

## 9. QA Checklist (Agent 4)

- [ ] Every MATLAB `.m` file has a corresponding Python module
- [ ] Every local function has a Python equivalent with matching signature
- [ ] All 6 strain/sex combinations processable
- [ ] All hardcoded constants in `config.py` (none scattered in code)
- [ ] Direction correctness sign convention matches biological meaning
- [ ] Taxis turn extraction produces same event count on reference data
- [ ] FFT frequency axis correct (Hz, not rad/s)
- [ ] Sprint zone threshold (3.2mm) applied correctly
- [ ] Cross-correlation reimplementation validated against known signal pairs
- [ ] All visualizations produce equivalent figure layouts
- [ ] No MATLAB-specific idioms leaked (1-indexed, column-major)
- [ ] All public functions have type hints and docstrings
- [ ] Tests pass with `pytest`
- [ ] No circular imports
- [ ] Pipeline runs end-to-end without data files (graceful error)
