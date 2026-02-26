# Extendiendo el ecosistema

Batuta Dots no es un sistema cerrado. Puedes crear tus propios skills, agentes, y workflows para que el ecosistema crezca con tus necesidades.

---

## Creando un skill nuevo

### Cuando crear un skill

- Repites el mismo patron en multiples proyectos
- Quieres que Batuta "sepa" hacer algo que hoy no sabe
- Encontraste una mejor practica que quieres estandarizar

### Como hacerlo

```
/create-skill mi-nuevo-skill
```

El **ecosystem-creator** te guia paso a paso:

1. **Nombre**: Como se llama el skill
2. **Proposito**: Que hace en una oracion
3. **Trigger**: Cuando debe activarse (palabras clave)
4. **Scope**: A que agente pertenece (pipeline, infra, observability)
5. **Auto-invoke**: Se activa solo o hay que llamarlo?
6. **Pasos**: La logica paso a paso

Resultado: Un archivo `SKILL.md` en `~/.claude/skills/mi-nuevo-skill/`

### Ejemplo: crear skill para React Native

```
/create-skill react-native-patterns
```

Defines:
- Proposito: "Patrones de React Native para apps moviles"
- Trigger: "react native, mobile, app movil, expo"
- Scope: pipeline
- Auto-invoke: true (cuando detecte React Native en el proyecto)

Ahora, cada vez que trabajes en un proyecto React Native, Batuta aplica automaticamente tus patrones estandarizados.

> Cuando creas un skill nuevo, puedes registrarlo en `skill-provisions.yaml` para que se auto-provisione en futuros proyectos con la misma tecnologia (v11.3).

---

## Creando un agente

```
/create-sub-agent mi-agente
```

Los agentes coordinan skills. Crealos cuando:
- Tienes 3+ skills que trabajan juntos en un dominio
- Necesitas logica de coordinacion entre skills
- Quieres encapsular un area de conocimiento

---

## Creando un workflow

```
/create-workflow mi-workflow
```

Los workflows son secuencias automaticas. Crealos cuando:
- Tienes una secuencia de pasos que repites frecuentemente
- Quieres automatizar un proceso multi-fase
- Necesitas combinar multiples skills en un orden especifico

---

## Skill Gap Detection automatico

No siempre necesitas crear skills proactivamente. El sistema detecta gaps automaticamente:

1. Empiezas a trabajar con una tecnologia nueva
2. **infra-agent** detecta que no hay skill para esa tecnologia
3. Te ofrece: crear skill local, global, o continuar sin el
4. Si creas el skill, se registra automaticamente

---

## Propagando skills entre proyectos

Si creas un skill en un proyecto y quieres que este disponible en todos:

**Opcion rapida** (un solo comando):
```bash
bash ~/batuta-dots/infra/sync.sh --push /path/to/mi-proyecto
```
Esto importa skills nuevos al hub, cross-syncs a Antigravity, y hace commit + push automaticamente.

**Opcion automatica**: Al terminar el proyecto, Batuta pregunta: "Quieres propagar estos skills a batuta-dots?" Si dices si, ejecuta el proceso por ti.

En tu proximo proyecto, el skill ya esta disponible via `/batuta-update`.

---

-> [Templates de equipo](templates-de-equipo.md) — Composiciones pre-configuradas
