# API foundation

`GET /v1/health` returns HTTP 200:

```json
{ "status": "ok", "service": "pesoflow-api" }
```

This is process liveness only. It checks no database or financial institution.
All financial endpoints are unimplemented and return 404. The Flutter demo
does not call this API. Authentication, authorization and persistence must be
implemented before exposing any user or financial data.
