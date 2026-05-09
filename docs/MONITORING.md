# Monitoring Guide
## Key Alerts
| Alert | Threshold | Severity |
|---|---|---|
| NodeHighCPU | > 85% for 5m | Warning |
| NodeHighMemory | > 90% for 5m | Critical |
| PodCrashLooping | > 0/min for 5m | Critical |
| HPAMaxed | at max for 15m | Warning |
