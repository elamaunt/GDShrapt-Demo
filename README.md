<!-- Logo -->
<p align="center">
  <img src="./docs/logo.png" alt="GDShrapt logo" width="128" />
</p>

# GDShrapt Tower Defence Demo

A small Tower Defence Godot project built specifically to **stress real-world GDScript refactoring cases** for **[GDShrapt](https://github.com/elamaunt/GDShrapt)**.

This repo exists for one reason: to demonstrate (and validate) **safe project‑wide rename with confidence levels** on a codebase that mixes strict typing, duck typing, dynamic dispatch, and `.tscn` wiring.

---

## What this Demo Shows

This project is used to demonstrate:

- **Project-wide rename** across:
  - inheritance chains (base ↔ derived overrides)
  - `super.*()` calls
  - `.tscn` signal connections (`method="..."`)
  - duck‑typed call sites (dynamic dispatch)
- **Confidence-aware classification**:
  - **Strict** → provably correct edits (safe to apply)
  - **Potential** → type-informed but not provably unique (preview-only)
  - **Name-match** → heuristic matches only (preview-only)
  - **Contract strings** → string-based API contracts like `has_method("...")` (preview-only by default)
- **Diff preview before apply**
- **Cross-file semantic resolution**
- **Type inference across control flow** (used to improve rename precision)
- **Explain mode** for “why is this edit considered Strict / preview-only?”

---

## Install GDShrapt CLI (Alpha)

> GDShrapt CLI is currently published as a **pre-release (alpha)**.

Install the CLI as a global .NET tool:

```bash
dotnet tool install -g GDShrapt.CLI --version 6.0.0-alpha.1
```

To update later:

```bash
dotnet tool update -g GDShrapt.CLI --version 6.0.0-alpha.1
```

Verify installation:

```bash
gdshrapt --version
gdshrapt --help
```

NuGet package page: https://www.nuget.org/packages/GDShrapt.CLI/

---

## Run GDShrapt on This Demo

From the repository root:

```bash
gdshrapt analyze .
```

Preview a safe project‑wide rename:

```bash
gdshrapt rename take_damage take_damage_renamed --diff
```

Apply only Strict (provably safe) edits:

```bash
gdshrapt rename take_damage take_damage_renamed --apply
```

Target a specific symbol by position (recommended for ambiguous names):

```bash
gdshrapt rename take_damage take_damage_renamed --file src/entities/enemies/enemy_basic.gd --line 42 --column 6 --diff
```

---

## Confidence Model

| Class | Meaning | Default in Base CLI |
|------|---------|---------------------|
| **Strict** | Proven semantic reference (type + symbol resolution) | ✅ Applied with `--apply` |
| **Potential** | Type-informed but not provably unique (duck-typed / dynamic) | ❌ Preview-only |
| **Name-match** | Name-only match (type unknown) | ❌ Preview-only |
| **Contract strings** | String-based API contracts (`has_method("...")`, etc.) | ❌ Preview-only (opt-in apply) |

### Why “Contract strings” are preview-only by default

Even if a rename is semantically correct, changing string literals can affect:
- reflection-like logic
- dynamic dispatch contracts
- external integrations / tooling
- intentional string-based routing

So GDShrapt separates them into a dedicated group and requires explicit opt-in to apply.

To apply them (when you’re sure):

```bash
gdshrapt rename take_damage take_damage_renamed --apply --include-contract-strings
```

---

## Example: Rename with Diff + Explain (Verbose)

Command used:

```bash
gdshrapt rename take_damage take_damage_renamed --diff --file src/entities/enemies/enemy_basic.gd --explain --verbose
```

<details>
<summary><strong>Full CLI output (click to expand)</strong></summary>

```text
gdshrapt rename take_damage take_damage_renamed --diff --file src\entities\enemies\enemy_basic.gd --explain --verbose
Operation: Rename symbol
File:    src/entities/enemies/enemy_basic.gd
From: take_damage
To:   take_damage_renamed

Apply policy: Strict only
Lower-confidence edits are preview-only in this mode

Summary:
  Files affected:   6
  Total edits:      12
  Strict edits:     10  (Certain)
  Potential edits:  0  (High/Medium)
  Name-match edits: 0  (Low)
  Contract strings: 2  (preview only)
  Applied edits:    10  (Strict)

Warnings:
  ! Contract string edits (string-based API contracts like has_method()) are preview-only (use --include-contract-strings to apply)
  Review details below

Run with --apply to apply Strict edits.
Edits:
  strict (10):
    src/core/damageable.gd
      L19:7 take_damage -> take_damage_renamed
        Reason: Duck-typed access on 'obj'
        Promoted: all evidence types covered
        Proof:
          1. EnemyBase (inherits Entity) via enemy at tower_aoe.gd:L104
          2. EnemyBase (inherits Entity) via target at tower_base.gd:L127
          3. Signal param Area2D - project Area2D descendants with take_damage: EnemyBasic, EnemyFast, EnemyTank, Entity (all covered)
          (filtered by scene collision_layer)
          (see collision pairs below)
        Evidence for 'obj':

          #1 src/entities/towers/tower_base.gd:L127  EnemyBase (arg at Damageable.apply_damage())
              src/entities/towers/tower_base.gd:L128  target
                src/entities/towers/tower_basic.gd:L42  target
                src/entities/towers/tower_base.gd:L123  current_target

          #2 src/entities/towers/tower_aoe.gd:L104  EnemyBase (element of Array[EnemyBase])
              src/entities/towers/tower_aoe.gd:L105  enemy
                src/entities/towers/tower_aoe.gd:L94  for enemy in enemies_in_range

          #3 src/entities/projectiles/projectile_base.gd:L98  Area2D (arg at Damageable.apply_damage())
              src/entities/projectiles/projectile_base.gd:L99  target_node
                src/entities/projectiles/projectile_base.gd:L94  area
                  src/systems/damage_zone.gd:L24  DamageZone.area_entered signal -> _on_area_entered(area: Area2D)
                  src/entities/projectiles/projectile_base.gd:L27  ProjectileBase.area_entered signal -> _on_area_entered(area: Area2D)

    src/entities/enemies/enemy_basic.gd
      L42:6 take_damage -> take_damage_renamed
        Reason: Reference in EnemyBasic (inherits Entity)

      L44:8 take_damage -> take_damage_renamed
        Reason: super.take_damage() call in derived class

    src/entities/enemies/enemy_fast.gd
      L37:6 take_damage -> take_damage_renamed
        Reason: Overrides Entity.take_damage

      L42:8 take_damage -> take_damage_renamed
        Reason: super.take_damage() call in derived class

    src/entities/enemies/enemy_tank.gd
      L68:6 take_damage -> take_damage_renamed
        Reason: Overrides Entity.take_damage

      L73:9 take_damage -> take_damage_renamed
        Reason: super.take_damage() call in derived class

      L173:32 take_damage -> take_damage_renamed
        Reason: Reference in EnemyTank (inherits Entity)

    src/entities/entity.gd
      L54:6 take_damage -> take_damage_renamed
        Reason: Member definition in Entity

    src/systems/damage_zone.gd
      L61:11 take_damage -> take_damage_renamed
        Reason: Duck-typed access on 'entity'
        Promoted: all evidence types covered
        Proof:
          1. Signal param Area2D - project Area2D descendants with take_damage: EnemyBasic, EnemyFast, EnemyTank, Entity (all covered)
          (filtered by scene collision_layer)
          (see collision pairs below)
        Evidence for 'entity':

          #1 src/systems/damage_zone.gd:L24  Area2D (via DamageZone.area_entered -> _on_area_entered() -> affected_entities)
              src/systems/damage_zone.gd:L47  affected_entities.append(area) <- _on_area_entered(area: Area2D) <- DamageZone.area_entered signal

          #2 src/entities/projectiles/projectile_base.gd:L27  Area2D (via ProjectileBase.area_entered -> _on_area_entered() -> affected_entities)
              src/systems/damage_zone.gd:L47  affected_entities.append(area) <- _on_area_entered(area: Area2D) <- ProjectileBase.area_entered signal

  contract strings (2):
    src/core/damageable.gd
      L13:25 take_damage -> take_damage_renamed
        Reason: has_method("take_damage") string literal
        Promoted: all evidence types covered
        Proof:
          1. EnemyBase (inherits Entity) via enemy at tower_aoe.gd:L103
          2. Signal param Area2D - project Area2D descendants with take_damage: EnemyBasic, EnemyFast, EnemyTank, Entity (all covered)
          (filtered by scene collision_layer)
          (see collision pairs below)

    src/systems/damage_zone.gd
      L60:25 take_damage -> take_damage_renamed
        Reason: has_method("take_damage") string literal
        Promoted: all evidence types covered
        Proof:
          1. Signal param Area2D - project Area2D descendants with take_damage: EnemyBasic, EnemyFast, EnemyTank, Entity (all covered)
          (filtered by scene collision_layer)
          (see collision pairs below)

Collision pairs:
  Area2D (mask=2) -> EnemyBasic (layer=2), EnemyFast (layer=2), EnemyTank (layer=2)
  DamageZone (mask=2) -> EnemyBasic (layer=2), EnemyFast (layer=2), EnemyTank (layer=2)
  EnemyBasic (mask=4) -> TowerBasic (layer=4), TowerSniper (layer=4)
  EnemyFast (mask=4) -> TowerBasic (layer=4), TowerSniper (layer=4)
  EnemyTank (mask=4) -> TowerBasic (layer=4), TowerSniper (layer=4)
  ProjectileBase (mask=2) -> EnemyBasic (layer=2), EnemyFast (layer=2), EnemyTank (layer=2)
  TowerBasic (mask=2) -> EnemyBasic (layer=2), EnemyFast (layer=2), EnemyTank (layer=2)
  TowerSniper (mask=2) -> EnemyBasic (layer=2), EnemyFast (layer=2), EnemyTank (layer=2)

--- a/src/core/damageable.gd
+++ b/src/core/damageable.gd
@@ -16,7 +16,7 @@
 # Applies damage to an object if possible
 static func apply_damage(obj, amount: int) -> bool:
        if can_take_damage(obj):
-               obj.take_damage(amount)
+               obj.take_damage_renamed(amount)
                return true
        return false

... (diff truncated here in README for brevity) ...

----- contract string edits (preview-only) -----
--- a/src/core/damageable.gd
+++ b/src/core/damageable.gd
@@ -10,7 +10,7 @@
                return false
        if not is_instance_valid(obj):
                return false
-       return obj.has_method("take_damage") and obj.has_method("is_alive")
+       return obj.has_method("take_damage_renamed") and obj.has_method("is_alive")
```

</details>

### Screenshot (optional)

If you prefer a screenshot instead of the long text block above, keep an image here:

```md
![CLI Rename Output](docs/rename-output.png)
```

---

## Why This Matters (vs Godot Built‑in Rename)

Godot’s built‑in rename is primarily **syntax-based** and is not designed to safely resolve:

- overrides across multiple files
- `.tscn` signal method references
- dynamic dispatch / duck typing patterns
- string-based API contracts (`has_method("...")`, etc.)
- “explainable” confidence classification

GDShrapt aims to make refactoring safer by:
- applying only **provably correct** edits by default
- surfacing dynamic usages separately (with rationale)
- always offering a **diff preview** before applying changes
- being **CI-friendly** (runs outside the editor)

---

## GDScript Patterns Covered

The demo intentionally mixes multiple styles found in production code:

| Pattern | Example Files |
|---------|---------------|
| **Strict typing** | `enemy_basic.gd`, `tower_basic.gd`, `game_manager.gd` |
| **Duck typing** | `enemy_fast.gd`, `tower_aoe.gd`, `damageable.gd`, `damage_zone.gd` |
| **Dynamic typing (Variant)** | `enemy_tank.gd`, `tower_placer.gd` |
| **Type inference (`:=`)** | `tower_sniper.gd` |
| **Signals** | `events.gd`, `enemy_base.gd`, `tower_base.gd`, `tower_button.gd` |
| **preload/load** | `enemy_spawner.gd`, `tower_placer.gd` |
| **Scene instancing** | `enemy_spawner.gd`, `tower_placer.gd` |
| **Class inheritance** | `entity.gd → enemy_base.gd → enemy_*.gd` |
| **@export variables** | `entity.gd`, `tower_base.gd`, `enemy_base.gd` |
| **Enums and constants** | `constants.gd` |
| **Lifecycle methods** | `_ready`, `_process`, `_physics_process` |
| **Physics and collisions** | `tower_base.gd`, `projectile_base.gd`, `projectile_aoe.gd` |
| **Arrays and dictionaries** | `enemy_spawner.gd`, `constants.gd`, `damage_zone.gd` |
| **UI and scene management** | `hud.gd`, `game_controller.gd`, `main_menu.gd` |

---

## Project Structure

```
src/
├── autoload/
├── core/
├── entities/
│   ├── enemies/
│   ├── towers/
│   └── projectiles/
├── systems/
├── ui/
└── scenes/
```

---

## Running the Game

Open the project in **Godot 4.2+** and run:

```
src/scenes/main_menu.tscn
```

---

## Feedback I’m Looking For

If you try GDShrapt on your own project, the most valuable reports are:

- cases where an edit should be **Strict** but remains preview-only
- false positives / false negatives in duck-typed detection
- performance characteristics on larger projects (load time, incremental runs)

---

## License

MIT License
