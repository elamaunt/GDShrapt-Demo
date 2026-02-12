# GDShrapt Tower Defence Demo

A real Godot 4 project used to demonstrate **GDShrapt CLI** capabilities:

- safe project-wide rename
- type-aware cross-file analysis
- scene + signal refactoring
- strict vs duck-typed confidence modes

This is not just a game — it is a **testbed for static analysis**.

👉 GDShrapt: https://github.com/elamaunt/GDShrapt

---

# Quick start

Install GDShrapt CLI (alpha):

```bash
dotnet tool install -g GDShrapt.CLI --prerelease
```

Run safe rename:

```bash
gdshrapt rename take_damage take_damage_renamed -p .
```

Preview with diff:

```bash
gdshrapt rename take_damage take_damage_renamed -p . --diff
```

Apply only **Strict** edits safely:

```bash
gdshrapt rename take_damage take_damage_renamed -p . --apply
```

---

# Why this demo exists

Godot projects mix:

- strict typing
- Variant/dynamic code
- duck typing (`has_method`)
- signals and `.tscn` connections
- inheritance across many files

This makes **safe refactoring extremely hard**.

This demo shows how GDShrapt handles all of it.

---

# Killer feature: safe project-wide rename

Example:

```bash
gdshrapt rename take_damage take_damage_renamed -p ./GDShrapt-Demo --diff
```

Result:

- ✅ updates overrides in derived classes  
- ✅ updates `super.take_damage()` calls  
- ✅ updates `.tscn` signal connections  
- ⚠️ flags duck-typed usages separately  
- ⚠️ isolates name-only heuristic matches  

Confidence levels:

| Level | Meaning |
|-------|---------|
Strict | Type-proven symbol reference |
Potential | Duck-typed call (e.g. `has_method`) |
Name-match | Text match with unknown type |

Only **Strict edits** are applied by default to prevent breaking dynamic gameplay code.

---

# What this project tests

The code intentionally mixes real-world GDScript patterns:

| Pattern | Purpose |
|--------|---------|
Strict typing | type inference and override safety |
Duck typing | confidence-aware rename |
Variant usage | flow-sensitive analysis |
Signals | `.tscn` method rename propagation |
Inheritance | base → derived method tracking |
preload/load | resource path analysis |
Scene instancing | cross-scene symbol usage |

---

# Project structure

```
src/
├── autoload/          # Events, GameManager
├── core/              # Base classes and interfaces
├── entities/
│   ├── enemies/       # Basic, Fast, Tank
│   ├── towers/        # Basic, Sniper, AOE
│   └── projectiles/
├── systems/           # Spawner, Damage zones
├── ui/
└── scenes/            # Includes signal connections
```

---

# Running the demo game

1. Open in **Godot 4.2+**
2. Run `src/scenes/main_menu.tscn`

---

# Running GDShrapt CLI on this project

Analyze everything:

```bash
gdshrapt analyze .
```

Check CI health:

```bash
gdshrapt check .
```

Find dead code:

```bash
gdshrapt dead-code .
```

Type coverage:

```bash
gdshrapt type-coverage .
```

Dependency graph:

```bash
gdshrapt deps .
```

---

# Why this matters

Godot’s built-in tooling cannot:

- rename across scenes safely
- distinguish typed vs duck-typed calls
- propagate refactors through signals
- provide confidence levels

GDShrapt adds **language-level refactoring safety** to GDScript.

---

# License

MIT
