# GDShrapt Tower Defence Demo

A demonstration Tower Defence game project for [GDShrapt](https://github.com/elamaunt/GDShrapt) - a GDScript static analysis platform.

## Project Purpose

This project demonstrates GDShrapt CLI capabilities through various GDScript patterns found in real Godot game development.

## GDScript Patterns

The project intentionally uses different coding styles to test the analyzer:

| Pattern | Example Files |
|---------|---------------|
| **Strict typing** | `enemy_basic.gd`, `tower_basic.gd`, `game_manager.gd` |
| **Duck typing** | `enemy_fast.gd`, `tower_aoe.gd`, `damageable.gd` |
| **Dynamic typing (Variant)** | `enemy_tank.gd`, `tower_placer.gd` |
| **Signals** | `events.gd`, `enemy_base.gd`, `tower_base.gd` |
| **preload/load** | `enemy_spawner.gd` (preload), `tower_placer.gd` (load) |
| **Scene instancing** | `enemy_spawner.gd`, `tower_placer.gd` |
| **Class inheritance** | `entity.gd` → `enemy_base.gd` → `enemy_*.gd` |
| **@export variables** | `entity.gd`, `tower_base.gd`, `enemy_base.gd` |
| **Enums and constants** | `constants.gd` |
| **Lifecycle methods** | `_ready`, `_process`, `_physics_process` in all classes |
| **Physics and collisions** | `tower_base.gd`, `projectile_base.gd` |
| **Arrays and dictionaries** | `enemy_spawner.gd`, `constants.gd` |

## Project Structure

```
src/
├── autoload/          # Singletons (Events, GameManager)
├── core/              # Base classes and constants
├── entities/          # Game entities
│   ├── enemies/       # Enemies (3 types)
│   ├── towers/        # Towers (3 types)
│   └── projectiles/   # Projectiles
├── systems/           # Game systems
├── ui/                # User interface
└── scenes/            # Scenes (.tscn)
```

## Gameplay

- Enemies move along a predefined path
- Player places towers for gold
- 3 tower types: Basic, Sniper, AOE
- 3 enemy types: Basic, Fast, Tank
- 10 waves with increasing difficulty
- Victory after completing all waves
- Defeat if enemies destroy the base

## Running

1. Open the project in Godot 4.2+
2. Run the main scene `src/scenes/main_menu.tscn`

## License

MIT License
