# Caso de Uso: Onboarding Digital de Empleados

Un sistema para gestionar el proceso de ingreso de nuevos empleados: documentos requeridos, capacitaciones, asignacion de recursos, y seguimiento de completitud.

---

## El problema

Cuando entra un empleado nuevo, pasa esto:
- RRHH le envia una lista de documentos por email (cedula, certificados, EPS, fondo de pension)
- El empleado envia documentos por WhatsApp, email, o los trae fisicos
- Nadie sabe si ya entrego todo o falta algo hasta que alguien revisa manualmente
- Las capacitaciones de induccion dependen de que alguien "se acuerde" de programarlas
- El acceso a sistemas (email corporativo, ERP, herramientas) tarda dias porque nadie coordina con TI
- A los 3 meses, nadie sabe si el empleado completo su proceso de induccion

---

## Lo que vas a construir

Un sistema web con:
- Checklist de documentos por tipo de cargo (administrativo, operativo, temporal)
- Portal donde el empleado sube sus documentos
- Flujo de revision y aprobacion de documentos
- Calendario de capacitaciones con asignacion automatica segun cargo
- Solicitudes automaticas a TI para creacion de accesos
- Dashboard de completitud: % de onboarding completado por empleado

---

## Flujo SDD completo

### Paso 1: Preparar
```
/sdd-init
```

### Paso 2: Iniciar
```
/sdd-new onboarding-digital
```
Contexto: "Sistema de onboarding para nuevos empleados. Checklist de documentos configurable por tipo de cargo, portal de carga, flujo de aprobacion, calendario de capacitaciones, y tracking de completitud."

### Paso 3: Discovery

Las 5 preguntas:
1. **Tipos de caso**: Empleado directo, temporal, practicante, contratista
2. **Excepciones**: Documento rechazado (reenvio), empleado que no completa a tiempo, reingreso
3. **Categorias externas**: tipos de documento por cargo, capacitaciones por area, accesos por rol
4. **Participantes**: empleado nuevo, RRHH, jefe directo, TI, SST (seguridad y salud)
5. **Ramas**: creacion perfil → documentos → capacitaciones → accesos → evaluacion → cierre (paralelo: documentos + capacitaciones + accesos)

### Paso 4: Skills que se activan

| Skill | Por que se activa |
|-------|------------------|
| **process-analyst** | 4 tipos de empleado con checklists distintos + actividades en paralelo |
| **compliance-colombia** | Datos personales de empleados (Ley 1581, habeas data) |
| **security-audit** | Documentos sensibles (cedula, certificados medicos) requieren almacenamiento seguro |

### Paso 5: Fast-forward
```
/sdd-ff
```

### Paso 6-8: Implementar, verificar, archivar
```
/sdd-apply onboarding-digital
/sdd-verify onboarding-digital
/sdd-archive onboarding-digital
```

---

## Gates que pasas

| Gate | Que verifica en este caso |
|------|--------------------------|
| **G0.5** | Mapeaste los 4 tipos de empleado? Documentaste las actividades en paralelo? Listaste todos los participantes? |
| **G1** | El scope es onboarding (no incluye nomina, evaluacion de desempeno, ni gestion de vacaciones)? |
| **G2** | El portal de carga funciona? Los flujos paralelos se coordinan correctamente? El dashboard refleja el estado real? |

---

## Resultado final

- Portal de onboarding para nuevos empleados
- Checklist configurable por tipo de cargo
- Flujo de aprobacion de documentos
- Calendario de capacitaciones automatico
- Solicitudes a TI automatizadas
- Dashboard de completitud para RRHH

---

## Siguientes pasos

- Integrar con nomina para activar el pago una vez onboarding este completo
- Agregar encuesta de satisfaccion del nuevo empleado al cierre
- Implementar onboarding de re-ingreso (empleados que vuelven)
- → Ver [Seleccion de personal](seleccion-personal.md) para el inicio del ciclo

---

→ [Volver al indice de casos](../README.md)
