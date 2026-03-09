---
name: performance-testing
description: >
  Use when testing performance: load testing, Core Web Vitals, benchmarking, k6, stress test, scalability.
  Trigger: "performance", "load test", "stress test", "benchmark", "Core Web Vitals",
  "k6", "scalability", "latency", "throughput", "p95", "p99".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-03-09"
  scope: [pipeline]
  auto_invoke: "Performance testing, load testing, benchmarking, Core Web Vitals optimization"
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep Bash WebSearch
---

# Performance Testing

## Purpose

Performance validation for APIs and web applications. Covers load testing (k6, Artillery), Core Web Vitals optimization (LCP, FID, CLS), stress testing, benchmarking, and performance budgets in CI/CD. Produces baseline metrics and regression detection reports.

## When to Use

- Load testing an API or web application before launch
- Establishing performance baselines before optimization
- Validating Core Web Vitals (LCP, FID, CLS) for web applications
- Stress testing to find breaking points
- Setting up performance budgets in CI/CD
- During sdd-verify Step 4.5 as performance validation layer
- When investigating performance regressions or bottlenecks

## Critical Patterns

### Pattern 1: Establish Baseline Before Optimization

Never optimize without measuring first. Every performance improvement starts with a baseline.

```
BASELINE PROTOCOL:
├── 1. Measure current state under realistic conditions
│   ├── Use production-like data volumes (not empty databases)
│   ├── Use realistic user behavior patterns (not single-endpoint hammering)
│   └── Measure at multiple percentiles: p50, p95, p99 (not just average)
│
├── 2. Document the baseline
│   ├── Date, environment, data volume, concurrent users
│   ├── Response times: p50, p95, p99
│   ├── Error rate under load
│   └── Resource utilization: CPU, memory, connections
│
├── 3. Set targets
│   ├── Based on SLA requirements or user experience research
│   ├── "Faster" is not a target — "p95 < 500ms" is a target
│   └── Include degradation thresholds: "acceptable up to 200 concurrent users"
│
└── 4. After optimization, compare against baseline
    ├── Same conditions, same data volume
    ├── Statistical significance: run multiple iterations
    └── Report improvement as percentage with confidence interval
```

### Pattern 2: Core Web Vitals Targets

For web applications, these are the thresholds that matter:

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| **LCP** (Largest Contentful Paint) | < 2.5s | 2.5s - 4.0s | > 4.0s |
| **FID** (First Input Delay) / **INP** (Interaction to Next Paint) | < 100ms / < 200ms | 100-300ms / 200-500ms | > 300ms / > 500ms |
| **CLS** (Cumulative Layout Shift) | < 0.1 | 0.1 - 0.25 | > 0.25 |
| **TTFB** (Time to First Byte) | < 800ms | 800ms - 1.8s | > 1.8s |

Target: "Good" rating for 75th percentile of real users (not lab conditions).

### Pattern 3: Performance Budgets in CI/CD

Prevent regressions by failing the build when performance degrades:

```yaml
# Example: Lighthouse CI performance budget
ci:
  assert:
    assertions:
      "first-contentful-paint": ["error", {"maxNumericValue": 2000}]
      "largest-contentful-paint": ["error", {"maxNumericValue": 2500}]
      "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}]
      "total-blocking-time": ["error", {"maxNumericValue": 300}]
      "interactive": ["error", {"maxNumericValue": 3500}]
```

```
BUDGET ENFORCEMENT:
├── Define budgets per metric (response time, bundle size, asset size)
├── Integrate into CI pipeline — budget violation = build failure
├── Review budgets quarterly — adjust as the application grows
└── Document exceptions: if a page intentionally exceeds a budget, explain why
```

## Decision Trees

| Scenario | Test Type | Tool | Key Metrics |
|----------|-----------|------|-------------|
| "Will this API handle production traffic?" | Load test | k6, Artillery | p95 response time, error rate, throughput |
| "Where does the system break?" | Stress test | k6 (ramping VUs) | Breaking point VUs, first error threshold |
| "Does performance degrade over time?" | Endurance/Soak test | k6 (constant load, 2-8h) | Memory leaks, connection pool exhaustion |
| "Can we handle 10x growth?" | Scalability test | k6 + auto-scaling | Scaling trigger time, cost per request at scale |
| "Is the website fast for users?" | Core Web Vitals | Lighthouse, WebPageTest | LCP, FID/INP, CLS, TTFB |
| "Did this PR make things slower?" | Regression test | Lighthouse CI | Budget assertions, before/after comparison |
| "Which query is slow?" | Profiling | EXPLAIN ANALYZE, pg_stat | Query plan, seq scans, index usage |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Optimizing without baseline | Cannot prove improvement, may make things worse | Measure first, optimize second, compare against baseline |
| Using averages only | Averages hide tail latency — 1% of users may wait 10x longer | Report p50, p95, p99 percentiles |
| Testing with empty database | Production has millions of rows, behavior differs drastically | Use production-like data volumes (anonymized if needed) |
| Single-endpoint load test | Real users hit multiple endpoints concurrently | Use realistic user scenarios with mixed endpoints |
| Testing from same machine as server | Network latency = 0, CPU shared — results are fiction | Test from a separate machine or cloud instance |
| "It's fast on my machine" | Developer machines have SSDs, fast CPUs, no contention | Test under production-like conditions |
| Bundle size > 500KB JS (uncompressed) | Slow parse and execute on mobile devices | Code splitting, tree shaking, lazy loading |
| No performance budget | Regressions sneak in over time unnoticed | Set budgets in CI, fail builds on violations |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| SDD Pipeline | Invoked during sdd-verify Step 4.5 as performance validation |
| CI/CD | Lighthouse CI or k6 in GitHub Actions for regression detection |
| Database | EXPLAIN ANALYZE for query optimization, pg_stat for monitoring |
| Frontend | Core Web Vitals via Lighthouse, bundle analysis via `next build --analyze` |
| API | k6 or Artillery for load testing endpoints |

## Code Examples

```javascript
// Example: k6 load test for an API
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');

export const options = {
  stages: [
    { duration: '2m', target: 10 },   // warm-up
    { duration: '5m', target: 50 },   // normal load
    { duration: '2m', target: 100 },  // peak load
    { duration: '2m', target: 0 },    // cool-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    errors: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('http://localhost:3000/api/items');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  errorRate.add(res.status !== 200);
  responseTime.add(res.timings.duration);
  sleep(1);
}
```

```bash
# Example: Lighthouse CI in GitHub Actions
# .github/workflows/perf.yml
name: Performance Budget
on: [pull_request]
jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build
      - uses: treosh/lighthouse-ci-action@v12
        with:
          configPath: ./lighthouserc.json
          uploadArtifacts: true
```

## Commands

```bash
# Run k6 load test
k6 run loadtest.js

# Run k6 with HTML report
k6 run loadtest.js --out json=results.json
# Then convert: k6-to-html results.json

# Lighthouse audit for Core Web Vitals
npx lighthouse http://localhost:3000 --only-categories=performance --output=json --output-path=./perf-report.json

# Analyze Next.js bundle size
ANALYZE=true npx next build

# PostgreSQL: find slow queries
psql -c "SELECT query, mean_exec_time, calls FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 10;"

# Check for N+1 queries (look for repeated similar queries)
grep -c "SELECT" app.log | sort -rn | head -5
```

## Rules

- NEVER optimize without a baseline measurement — "faster" without numbers is meaningless
- Always report percentiles (p50, p95, p99), not just averages — averages hide tail latency
- Test with production-like data volumes — empty databases give false confidence
- Performance budgets in CI are mandatory for web applications — regressions must be caught automatically
- Core Web Vitals targets: LCP < 2.5s, INP < 200ms, CLS < 0.1 — "Good" for 75th percentile
- Run load tests from a separate machine from the server — same-machine tests are unreliable
- Document test conditions alongside results (date, data volume, environment, concurrent users)
- Statistical significance requires multiple iterations — a single run is an anecdote, not data

## What This Means (Simply)

> **For non-technical readers**: This skill makes sure our software is fast enough for real users, not just on a developer's powerful computer. Think of it like load-testing a bridge before opening it to traffic — you need to know it can handle rush hour, not just one car. We measure how fast pages load, how many users the system can handle before slowing down, and we set automatic alarms that go off if a code change makes things slower. A slow application loses users — studies show that every extra second of load time reduces conversions by 7%.
