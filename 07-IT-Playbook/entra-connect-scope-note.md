## Entry — Entra ID Hybrid Identity: Scope Note

**Category:** Architecture Decision / Scope Boundary
**Related Project:** windows-enterprise-lab, 05-Microsoft-Entra-ID-Lab

### What Was Built
A Microsoft Entra ID (Azure AD) tenant (jovianneyymail.onmicrosoft.com) provisioned
as Global Administrator, with a cloud user (trainer01) manually created to mirror
the same user existing on-prem in the AD domain (jovilab.local). This demonstrates
the hybrid identity model — one identity, represented in both an on-prem directory
and a cloud directory.

### What Was Not Built
Microsoft Entra Connect (the automated sync engine that keeps on-prem AD and
Entra ID continuously in sync in a production environment) was not deployed in
this lab.

### Why
Entra Connect requires a domain controller with outbound sync permissions to
Microsoft's cloud endpoints. Running that on a home-network domain controller
introduces more external exposure than this lab environment is scoped for.
The manual dual-creation approach demonstrates the same underlying concept —
identity federation between on-prem and cloud — without that exposure.

### Next Step (If Revisited)
A follow-up lab could stand up Entra Connect on an isolated VM with a scoped
firewall rule set, to demonstrate the live sync process end to end.
