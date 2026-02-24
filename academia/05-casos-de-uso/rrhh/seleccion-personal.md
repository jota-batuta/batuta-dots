# Caso de Uso: Sistema de Seleccion de Personal

Un sistema para recibir hojas de vida, evaluarlas automaticamente contra el perfil del cargo, y generar un ranking de candidatos con justificacion.

---

## El problema

En empresas medianas, el proceso de seleccion funciona asi:
- Se publica la vacante en portales (elempleo, Computrabajo, LinkedIn)
- Llegan 200+ hojas de vida por email o portal
- Alguien las revisa una por una (2-3 minutos por HV × 200 = dias de trabajo)
- La revision es subjetiva: depende de quien las lea y su estado de animo
- No hay trazabilidad de por que se descarto a alguien
- Cuando el candidato elegido no acepta, hay que empezar de nuevo

---

## Lo que vas a construir

Un sistema web con:
- Carga masiva de hojas de vida (PDF, Word, imagen)
- Extraccion automatica de datos (nombre, experiencia, educacion, habilidades)
- Evaluacion contra perfil del cargo usando IA
- Ranking de candidatos con puntaje y justificacion
- Dashboard del proceso: candidatos por etapa, tiempo promedio, tasa de aceptacion
- Cumplimiento de privacidad (Ley 1581, habeas data)

---

## Flujo SDD completo

### Paso 1: Preparar
```
/sdd-init
```

### Paso 2: Iniciar
```
/sdd-new screening-hojas-vida
```
Contexto: "Sistema de evaluacion automatica de hojas de vida. Debe extraer datos de PDFs y Word, evaluar contra perfil del cargo con IA, generar ranking con justificacion, y cumplir con Ley 1581 de proteccion de datos personales."

### Paso 3: Discovery

Las 5 preguntas:
1. **Tipos de caso**: HV en PDF, Word, imagen escaneada; perfiles tecnicos, administrativos, operativos
2. **Excepciones**: HV ilegible, HV sin datos clave, candidato interno, referido
3. **Categorias externas**: competencias por cargo, niveles de experiencia, instituciones educativas
4. **Participantes**: candidato, reclutador, jefe del area solicitante, legal (privacidad)
5. **Ramas**: recepcion → extraccion → evaluacion → ranking → entrevista → oferta → contratacion (+ rama rechazo con notificacion)

### Paso 4: Skills que se activan

| Skill | Por que se activa |
|-------|------------------|
| **process-analyst** | Multiples tipos de HV y perfiles con flujos distintos |
| **llm-pipeline-design** | IA para evaluar competencias y generar justificaciones |
| **compliance-colombia** | Datos personales sensibles (Ley 1581, habeas data, SIC 002/2024) |
| **recursion-designer** | Las competencias por cargo cambian con cada vacante nueva |
| **security-audit** | Datos personales de candidatos requieren control de acceso estricto |

### Paso 5: Fast-forward
```
/sdd-ff
```

### Paso 6-8: Implementar, verificar, archivar
```
/sdd-apply screening-hojas-vida
/sdd-verify screening-hojas-vida
/sdd-archive screening-hojas-vida
```

---

## Gates que pasas

| Gate | Que verifica en este caso |
|------|--------------------------|
| **G0.5** | Mapeaste todos los formatos de HV? Documentaste el flujo de datos personales? Listaste las competencias por perfil? |
| **G1** | El scope es screening (no incluye gestion de nomina ni contratacion completa)? El tratamiento de datos cumple Ley 1581? |
| **G2** | La extraccion funciona con PDF/Word/imagen? El ranking es consistente? El consentimiento de datos se registra? Los datos se pueden eliminar (derecho de supresion)? |

---

## Consideraciones especiales de privacidad

Este caso activa `compliance-colombia` con fuerza:
- **Consentimiento previo**: el candidato debe autorizar el tratamiento de datos antes de cargar su HV
- **Test de proporcionalidad**: la IA solo evalua competencias relevantes al cargo (no religion, orientacion, etc.)
- **Derecho de supresion**: el candidato puede pedir que eliminen sus datos en cualquier momento
- **PII stripping**: los datos personales se separan de la evaluacion (la IA no ve nombre ni foto)

---

## Resultado final

- Sistema de carga y extraccion de HV funcionando
- Evaluacion automatica con justificacion transparente
- Ranking de candidatos por puntaje
- Cumplimiento de Ley 1581 con consentimiento y supresion
- Dashboard de proceso de seleccion

---

## Siguientes pasos

- Integrar con portales de empleo (elempleo, Computrabajo) para carga automatica
- Agregar modulo de entrevistas con evaluacion estructurada
- Implementar analytics de diversidad e inclusion
- → Ver [Onboarding digital](onboarding-digital.md) para continuar el ciclo de RRHH

---

→ [Volver al indice de casos](../README.md)
