# Security Guide
| Control | Implementation |
|---|---|
| Private nodes | enable_private_nodes = true |
| Workload Identity | workload_pool = project.svc.id.goog |
| Shielded nodes | Secure boot + vTPM |
| Binary Authorization | PROJECT_SINGLETON_POLICY_ENFORCE |
| Network policy | Calico, default-deny per namespace |
