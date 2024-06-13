---
toc: false
---

```js
const permits = FileAttachment("la_permits_issued.parquet").parquet();
```

```js 
const formattedPermits = view(Inputs.table(permits, {
  format: {
    issue_date: (x) => new Date(x).toISOString().slice(0, 10),
    submitted_date: (x) => new Date(x).toISOString().slice(0, 10),
    status_date: (x) => new Date(x).toISOString().slice(0, 10),
    refresh_time: (x) => new Date(x).toISOString().slice(0, 10),
  }
}))
```

```js echo
formattedPermits
```
