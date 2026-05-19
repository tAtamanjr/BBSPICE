# Thesis LaTeX Template

This template is prepared for XeLaTeX or LuaLaTeX because Polish language support and system fonts are handled through `fontspec` and `polyglossia`.

## Build

From `Thesis/latex`:

```sh
make
```

Or manually:

```sh
xelatex main.tex
biber main
xelatex main.tex
xelatex main.tex
```

`latexmk -xelatex main.tex` also works if `latexmk` is installed.

## Editing Flow

Change diploma metadata in `metadata.tex`.

Move text from the previous PDF into files in `chapters/`. Keep each chapter focused on one job:

- `01-wstep.tex`: problem, goal, scope, structure.
- `02-podstawy-teoretyczne.tex`: circuit theory and SPICE background.
- `03-modified-nodal-analysis.tex`: MNA equations and stamping rules.
- `04-projekt-programu.tex`: architecture of the Swift project.
- `05-implementacja.tex`: parser, stamps, matrices, solver.
- `06-testy.tex`: unit tests and validation cases.
- `07-podsumowanie.tex`: conclusions and future work.

## Suggested Writing Improvements

Prefer one term consistently: use `węzły`, `elementy`, `stemple`, `macierz układu`, and `wektor prawej strony`. Avoid mixing Polish, English, and Ukrainian terms inside the same paragraph unless the English term is introduced explicitly.

In theoretical sections, introduce MNA from the limitation of classical nodal analysis: voltage sources and controlled sources are easier to represent after adding extra unknown currents.

In implementation sections, connect code concepts directly to theory: `Stamp` corresponds to a local matrix contribution, `Parser` maps text netlists to stamps, and `Solver` assembles and solves the global linear system.
