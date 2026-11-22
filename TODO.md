# Next development steps

1. Register real Discord slash commands (`/deobfuscate`, `/analyze`, `/beautify`, `/help`).
2. Add safe `.lua` and `.txt` attachment downloading with strict content-length and timeout limits.
3. Add test fixtures for common loader syntax variations.
4. Improve Lua parsing with a real parser before attempting transformations.
5. Keep all processing static. Never execute user submissions.
