# Seguridad desde cero

Batuta Dots incluye un skill dedicado a seguridad: **security-audit**. No necesitas ser experto en seguridad — el agente contratado revisa tu codigo y te dice que corregir.

---

## Por que importa

Si construyes software que maneja datos de usuarios, clientes, o empresas, la seguridad no es opcional. Un error puede significar:
- Datos de clientes expuestos
- Multas regulatorias (en Colombia, Ley 1581)
- Perdida de confianza del cliente
- Responsabilidad legal

---

## Que revisa security-audit

### Los 10 puntos del checklist

| # | Que revisa | Por que |
|---|-----------|---------|
| 1 | Validacion de entrada | Evitar inyeccion SQL, XSS |
| 2 | Autenticacion | Verificar que el login es seguro |
| 3 | Autorizacion | Verificar que cada usuario ve solo lo suyo |
| 4 | Manejo de secretos | API keys, passwords no en codigo |
| 5 | Dependencias | Librerias con vulnerabilidades conocidas |
| 6 | Configuracion | Headers de seguridad, CORS, HTTPS |
| 7 | Logging | Registrar acciones sin exponer datos sensibles |
| 8 | Manejo de errores | No mostrar stack traces al usuario |
| 9 | Almacenamiento de datos | Encripcion, hashing de passwords |
| 10 | API security | Rate limiting, tokens, CSRF |

### Seccion especial: IA y Claude

Si tu proyecto usa IA (LLM, clasificadores), security-audit agrega:
- **Prompt injection**: Tu sistema puede ser manipulado via input?
- **Control de costos**: Hay limites de tokens/llamadas?
- **PII en prompts**: Datos personales llegan al modelo sin anonimizar?

---

## Cuando se activa en v15

En v15, security-audit es un skill asignado al **quality-agent**. Se activa en tres escenarios:

1. **Durante research**: Cuando el agente contratado investiga antes de implementar (research-first), revisa riesgos de seguridad existentes.
2. **Durante verificacion** (`/sdd-verify`): Como capa transversal de la Piramide de Validacion.
3. **Manual**: Puedes pedir una auditoria en cualquier momento.

Ya no hay gates formales de 8 niveles. En modo SPRINT (0 gates), el quality-agent ejecuta security-audit como parte de `/sdd-verify`. En modo COMPLETO (1 gate en Design), la seguridad se valida en el artifact de diseno antes de la aprobacion.

---

## Ejemplo practico

Construiste una API con login. El quality-agent ejecuta security-audit y produce:

```
Auditoria de Seguridad: mi-api

[PASS] Passwords hasheados con bcrypt
[PASS] Tokens JWT con expiracion
[WARN] No hay rate limiting en /login — riesgo de fuerza bruta
[FAIL] API key hardcoded en config.ts linea 23
[FAIL] Endpoint /users no valida autorizacion — cualquier usuario ve todos

Recomendaciones:
1. Mover API key a variable de entorno
2. Agregar middleware de autorizacion a /users
3. Implementar rate limiting (5 intentos/minuto en /login)
```

---

## Que hacer cuando falla algo

| Severidad | Accion |
|-----------|--------|
| **FAIL** | Arreglar antes de deploy. `/sdd-verify` no pasa sin resolver FAILs |
| **WARN** | Evaluar riesgo. Documentar si aceptas el riesgo |
| **PASS** | Todo bien, seguir adelante |

---

## Buenas practicas basicas

Aunque no seas experto en seguridad, estas reglas te cubren el 80%:

1. **Nunca** pongas passwords, API keys, o tokens en el codigo. Usa variables de entorno.
2. **Siempre** valida lo que el usuario envia antes de procesarlo.
3. **Siempre** hashea passwords (nunca guardarlos en texto plano).
4. **Siempre** verifica que el usuario tiene permiso antes de mostrar datos.
5. **Siempre** usa HTTPS en produccion.

Batuta te recuerda estas reglas automaticamente cuando el quality-agent ejecuta security-audit.

---

Ahora conoces las herramientas basicas. En el siguiente nivel, aprenderemos a usarlas para depurar y validar:

-> [Depurando tu trabajo](../03-nivel-dos/depurando-tu-trabajo.md) — sdd-verify y la Piramide de Validacion
