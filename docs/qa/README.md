# Quality Assurance — Batuta.Dots

Indice maestro de todos los reportes de calidad del ecosistema.

---

## Estructura

```
docs/qa/
  ├── audits/              Auditorias de calidad estructural (por version)
  ├── corrections/         Logs de correcciones aplicadas (por version)
  └── integration-tests/   Tests de integracion — journey del usuario
```

---

## Auditorias de Calidad

Verifican la **estructura interna** del ecosistema: consistencia numerica, archivos faltantes, DRY violations, cross-references.

| Version | Archivo | Hallazgos | Resultado |
|---------|---------|-----------|-----------|
| v5 | [audits/v5-calidad.md](audits/v5-calidad.md) | 13 hallazgos | Corregidos en v5/v6 |
| v6 | [audits/v6-calidad.md](audits/v6-calidad.md) | 13 hallazgos | Corregidos en v6 |
| v7 | [audits/v7-calidad.md](audits/v7-calidad.md) | Auditoria post-teams | Corregidos en v7.1 |
| v9 | [audits/v9-calidad.md](audits/v9-calidad.md) | Auditoria post-restructure | Corregidos en v9 |
| v13 | [audits/v13-calidad.md](audits/v13-calidad.md) | Skills 2.0, SDK agents, domain agents | PASS (3 correcciones menores) |

## Logs de Correcciones

Documentan **que se corrigio** en cada version, archivo por archivo.

| Version | Archivo |
|---------|---------|
| v5 | [corrections/v5-correcciones.md](corrections/v5-correcciones.md) |
| v6 | [corrections/v6-correcciones.md](corrections/v6-correcciones.md) |
| v7 | [corrections/v7-correcciones.md](corrections/v7-correcciones.md) |
| v9 | [corrections/v9-correcciones.md](corrections/v9-correcciones.md) |
| v9.2 | [corrections/v9.2-correcciones.md](corrections/v9.2-correcciones.md) |
| v13 | [corrections/v13-correcciones.md](corrections/v13-correcciones.md) |

## Tests de Integracion

Simulan la **experiencia del usuario** siguiendo cada guia paso a paso. Identifican donde el ecosistema falla, confunde, o genera friccion en el journey de idea → producto.

| Guia | Archivo | Version | Estado |
|------|---------|---------|--------|
| Next.js SaaS | [integration-tests/nextjs-saas.md](integration-tests/nextjs-saas.md) | v9.0 | 12 hallazgos (10 corregidos en v9.1) |
| Next.js SaaS (revalidacion) | [integration-tests/nextjs-saas-revalidation.md](integration-tests/nextjs-saas-revalidation.md) | v9.1 | 7 abiertos (8 corregidos, 2 parciales, 3 nuevos) |
| Batuta App | [integration-tests/batuta-app.md](integration-tests/batuta-app.md) | v9.1 | 3 hallazgos (0C, 1I, 2M) |
| CLI Python | [integration-tests/cli-python.md](integration-tests/cli-python.md) | v9.1 | 5 hallazgos (1C, 2I, 2M) |
| Refactoring Legacy | [integration-tests/refactoring-legacy.md](integration-tests/refactoring-legacy.md) | v9.1 | 6 hallazgos (0C, 3I, 3M) |
| Data Pipeline | [integration-tests/data-pipeline.md](integration-tests/data-pipeline.md) | v9.1 | 7 hallazgos (2C, 2I, 3M) |
| n8n Automation | [integration-tests/n8n-automation.md](integration-tests/n8n-automation.md) | v9.1 | 7 hallazgos (0C, 3I, 4M) |
| LangChain Gmail Agent | [integration-tests/langchain-gmail-agent.md](integration-tests/langchain-gmail-agent.md) | v9.1 | 8 hallazgos (1C, 3I, 4M) |
| FastAPI Service | [integration-tests/fastapi-service.md](integration-tests/fastapi-service.md) | v9.1 | 9 hallazgos (3C, 4I, 2M) |
| Temporal.io App | [integration-tests/temporal-io-app.md](integration-tests/temporal-io-app.md) | v9.1 | 10 hallazgos (0C, 2I, 8M) |
| AI Agent ADK | [integration-tests/ai-agent-adk.md](integration-tests/ai-agent-adk.md) | v9.1 | 12 hallazgos (0C, 4I, 8M) |
| **Consolidado** | [integration-tests/consolidado-10-guias.md](integration-tests/consolidado-10-guias.md) | v9.1 | **74 hallazgos, 8 patrones sistemicos** |

---

> Ultima actualizacion: 2026-03-09 (v13)
