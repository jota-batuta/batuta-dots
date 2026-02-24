# Caso de Uso: Proyecto de Tesis o Investigacion

Como usar Batuta Dots para desarrollar el componente de software de tu tesis, trabajo de grado, o proyecto de investigacion — con la documentacion que tu director necesita ver.

---

## El problema

Si estas haciendo una tesis que incluye software, probablemente enfrentas esto:
- Tu director te pide "documentacion del sistema" pero no sabes que formato usar
- Empiezas a programar sin tener claro el alcance y terminas rehaciendo todo
- No tienes un proceso claro: hoy haces la base de datos, manana el frontend, pasado vuelves a la base de datos
- Cuando presentas avances, no puedes explicar POR QUE tomaste ciertas decisiones
- Al final, la documentacion la escribes a las carreras la noche antes de entregar

---

## Lo que vas a construir

El software de tu tesis, **pero con un proceso documentado** que incluye:
- Documento de exploracion (tu estado del arte aplicado)
- Propuesta tecnica con costos y beneficios
- Especificaciones formales (requisitos que se pueden verificar)
- Diseno de arquitectura con justificacion de decisiones
- Codigo implementado con documentacion inline
- Reporte de verificacion (tus pruebas)
- Archivo de lecciones aprendidas

Todo esto se genera como parte natural del proceso — no es trabajo extra.

---

## Flujo SDD completo

### Paso 1: Preparar tu proyecto
```
/sdd-init
```
Esto crea la estructura base. Claude detecta tu stack tecnologico.

### Paso 2: Explorar tu problema de investigacion
```
/sdd-new mi-tesis-nombre
```
Ejemplo: "Estoy desarrollando un sistema de clasificacion de texto para analizar sentimiento en resenas de productos colombianos. Necesito un clasificador que funcione con espanol colombiano informal."

### Paso 3: Discovery

Claude te hace las 5 preguntas que tu director tambien deberia hacerte:
1. **Tipos de caso**: Resenas positivas, negativas, neutras, mixtas, spam
2. **Excepciones**: Resenas en spanglish, con emojis, muy cortas (1-2 palabras)
3. **Categorias externas**: categorias de productos, plataformas de origen, dialectos
4. **Participantes**: el clasificador, el usuario final, los datos de entrenamiento
5. **Ramas del proceso**: recoleccion → limpieza → entrenamiento → evaluacion → despliegue

### Paso 4: Skills segun tu tema

Los skills que se activen dependen de tu tesis:

**Si tu tesis usa IA/ML**:
| Skill | Por que |
|-------|---------|
| **llm-pipeline-design** | Pipeline completo de clasificacion con las 6 fases |
| **data-pipeline-design** | Limpieza y preparacion de datos |

**Si tu tesis es un sistema de informacion**:
| Skill | Por que |
|-------|---------|
| **process-analyst** | Mapeo de procesos del negocio |
| **data-pipeline-design** | Integracion de datos |

**Si tu tesis maneja datos personales**:
| Skill | Por que |
|-------|---------|
| **compliance-colombia** | Ley 1581, consentimiento informado |

### Paso 5: Documentar todo (esto es oro para tu tesis)
```
/sdd-ff
```
Esto genera:
- **Propuesta** → Tu capitulo de "Solucion Propuesta"
- **Especificaciones** → Tu capitulo de "Requisitos"
- **Diseno** → Tu capitulo de "Arquitectura del Sistema"
- **Tareas** → Tu plan de trabajo

### Paso 6-8: Implementar, verificar, archivar
```
/sdd-apply mi-tesis-nombre
/sdd-verify mi-tesis-nombre
/sdd-archive mi-tesis-nombre
```

---

## Mapeo SDD → Capitulos de tesis

| Artefacto SDD | Capitulo de tesis |
|---------------|-------------------|
| Reporte de exploracion | Estado del arte / Marco teorico aplicado |
| Propuesta | Solucion propuesta / Metodologia |
| Especificaciones | Requisitos funcionales y no funcionales |
| Diseno | Arquitectura del sistema |
| Codigo | Implementacion |
| Reporte de verificacion | Pruebas y resultados |
| Archivo | Conclusiones y trabajo futuro |

---

## Gates que pasas

| Gate | Que verifica (y que tu director preguntaria) |
|------|----------------------------------------------|
| **G0.5** | Entiendes bien el problema? Revisaste alternativas? Definiste el alcance? |
| **G1** | La solucion es viable en el tiempo que tienes? No estas sobredimensionando? |
| **G2** | Funciona? Las pruebas lo demuestran? Puedes defenderlo en la sustentacion? |

---

## Resultado final

- Software funcionando con documentacion completa
- Artefactos SDD que mapean directamente a capitulos de tesis
- Historial de decisiones tecnicas con justificacion
- Evidencia de proceso metodico (importante para la sustentacion)
- Lecciones aprendidas documentadas

---

## Tips para la sustentacion

1. **Muestra el proceso, no solo el resultado**: Los artefactos SDD demuestran rigor metodologico
2. **Usa los gates como evidencia**: "Antes de implementar, verifique estos criterios..."
3. **Las especificaciones son verificables**: Given/When/Then es mas riguroso que "el sistema debe ser rapido"
4. **El diseno tiene justificacion**: Cada decision dice POR QUE, no solo QUE

---

## Siguientes pasos

- Usa los artefactos SDD como anexos tecnicos de tu tesis
- Si tu tesis tiene componente de emprendimiento → ver [Prototipo startup](prototipo-startup.md)
- Considera publicar tu skill personalizado si creaste uno para tu area de investigacion

---

→ [Volver al indice de casos](../README.md)
