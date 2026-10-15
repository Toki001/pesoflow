# Optional API foundation

`GET /v1/health` returns HTTP 200:

```json
{ "status": "ok", "service": "pesoflow-api" }
```

This checks process liveness, not a database or financial institution. Other
financial endpoints return 404. The Flutter app uses encrypted local repositories
and never requires this server. No login, profile, provider, financial persistence
or synchronization modules are implemented in the backend. Helmet and validation
remain in the minimal NestJS foundation; do not expose financial data through it.
