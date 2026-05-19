# Writing Notes

## Content

Make the thesis argument explicit early:

1. Classical nodal analysis is simple for resistive and current-source circuits.
2. Voltage sources and controlled sources require extra unknowns.
3. Modified Nodal Analysis gives a systematic matrix form for these cases.
4. The implemented program follows this structure directly through stamps, parser, and solver.

Use one recurring diagram in the text:

- input netlist
- parser
- element stamps
- global MNA matrix
- solver
- operating point result

This will make the implementation chapter easier to connect with the theory chapter.

## Terminology

Keep Polish technical terms consistent:

- `węzeł` for node
- `stempel` for stamp
- `macierz układu` for system matrix
- `wektor prawej strony` for right-hand-side vector
- `punkt pracy` for operating point
- `źródło sterowane` for controlled source

When an English term is important, introduce it once: `stempel (ang. stamp)`, `punkt pracy (ang. operating point)`, `Modified Nodal Analysis`.

## Style

Prefer short technical paragraphs. A good paragraph should usually do one of three things:

- define a concept
- explain why it is needed
- connect theory with the implementation

Avoid writing implementation details before the theoretical object is introduced. For example, describe the role of extra current unknowns before describing `newRow`.

## Suggested Chapter Improvements

In the MNA chapter, include at least one worked example: a voltage source in series with a resistor is enough. Show how the additional current unknown changes the matrix size.

In the implementation chapter, describe each main Swift type by responsibility, not by listing every function. For example: `Parser` validates the input structure, `Stamp` stores local matrix contributions, and `Solver` assembles the global matrix.

In the testing chapter, separate mathematical validation from parser validation. Mathematical tests should show that the solver gives expected voltages/currents. Parser tests should show that malformed netlists fail in controlled ways.

## Grammar And Polish Flow

Watch for mixed-language sentences. If a sentence starts in Polish, keep it Polish unless the English term is a formal name.

Use impersonal academic style consistently:

- Better: `W programie zaimplementowano parser plików tekstowych.`
- Avoid: `Zrobiłem parser, który czyta plik tekstowy.`

Prefer `układ równań liniowych` over loose phrases like `system matrix problem`.
