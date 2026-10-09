# Release validation — 2026-10-09

Release: `dist/Malom.dc42`, **419284 bytes**, tool **244**, volume suffix **D605**.

SHA-256:
```text
8ee9afccd96fb46d5dcb2fd07b7920ae4831ba71eff54cae4bbbdcc91b41b47f
```
Executable: **11776 bytes**, SHA-256:
```text
4edda1a14e9ceab3d0a182045938e3b7d0da1bee3b4f6ef91de6348150bdb800
```

## Completed checks

| Check | Recorded result |
| --- | --- |
| Native build | Pascal 3.26, code generator 3.16, linker 3.0; zero errors |
| Source/payload | Exact compiled source and linked executable verified |
| Floppy | DC42 checksums valid, all 800 Sony tags preserved; three matching own icons |
| Host rules | 15 checks, 10 complete games, 538 turns |
| Native basics | 14 checks, including captures, flying, invalid input and restart |
| Native capture cases | 7 checks, protected mills, all-in-mills exception and double mill |
| Native two-player games | 32-turn black win and 34-turn repetition draw |
| Native computer game | Complete 62-turn game, 31 automatic replies, black win |
| Rendering | 16 sampled frames, 64 repeated occupied-point submissions |
| Mouse | White point 1 and black point 9 correctly selected |
| Hard-disk installation | Native LOS Duplicate, copy to Games, floppy ejected, fresh tool launch and CPU reply |
| Coexistence | 19 prior tools retained; 77 immutable files byte-identical, including new tool files |
| Memory | Actual emulator RAM range verified as 1 MB |

Detailed JSON reports are in [validation/](validation/). Screenshots include
[native compiler](screenshots/native-compiler.png),
[zero-error linker](screenshots/native-linker.png),
[completed CPU game](screenshots/computer-game-finished.png) and
[installation alongside other games](screenshots/installed-with-other-games.png).
The reports retain local test environment paths as historical evidence.

## Scope

Tests ran in **LisaEm with LOS 3.1 and 1 MB guest RAM**. The application targets
native Apple Lisa 2 hardware; a physical Lisa 2 test is not yet recorded.
Native input used COPS events; tests did not directly modify game board RAM.
Rendering checks compare sampled frames, not continuous video. Board, numbers,
title, footer and unchanged HUD rows remained identical during repeated invalid
input; the typed-number row legitimately changes.

The hard-disk launch test used a fresh tool instance after native tool shutdown
and floppy ejection in the same emulator session; a separate cold boot was
not part of this test. Mutable data segments were excluded from the immutable
file comparison. The owned test emulator and VM were closed after testing.
