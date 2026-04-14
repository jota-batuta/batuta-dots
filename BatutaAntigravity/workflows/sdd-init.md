# /sdd-init

> Bootstrap Spec-Driven Development in this project. Detects project type (webapp, automation, ai-agent, infrastructure, data-pipeline, library) and creates the openspec/ directory structure. Provisions relevant skills from the hub based on tech stack detection.

## Instructions

1. Locate and read the `sdd-init` skill file at `.agent/skills/sdd-init/SKILL.md` or `~/.gemini/antigravity/skills/sdd-init/SKILL.md`.
2. Follow the skill instructions exactly to bootstrap the SDD structure.
3. The skill will detect the project type, create the appropriate `openspec/` directory, and provision relevant skills from the hub (43+ available) based on the detected tech stack.

If the skill file does not exist, tell the user:

```
El skill sdd-init no esta instalado. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
