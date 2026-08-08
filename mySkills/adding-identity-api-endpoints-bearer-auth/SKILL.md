---
name: adding-identity-api-endpoints-bearer-auth
description: 'Add Identity API endpoints with cookie and bearer-token auth in .NET 10 apps. Use when the user asks for /identity endpoints, MapIdentityApi, bearer tokens, dual authentication, MAUI/mobile clients, or API login and refresh flows.'
license: Apache-2.0
---

# Identity API Endpoints with Bearer Auth

Configure ASP.NET Core Identity so a .NET 10 app can serve both interactive web sign-in and external bearer-token clients. Use this skill when a Blazor or ASP.NET Core app needs `/identity` endpoints for mobile, desktop, or other API consumers.

## When to Use This Skill

- User wants `/identity/register`, `/identity/login`, or `/identity/refresh`
- User wants cookie and bearer auth side by side
- User wants Identity API endpoints for MAUI, mobile, or desktop clients
- User asks to map `MapIdentityApi<TUser>()`
- User needs authenticated API access without breaking the web UI login flow

## Prerequisites

- ASP.NET Core Identity is already configured
- Entity Framework stores are wired up
- .NET 10 project target

## Workflow

1. Configure authentication so the web UI keeps cookie-based sign-in.
2. Add bearer token support before the identity cookies are registered.
3. Configure `AddIdentityCore` with `RequireConfirmedAccount` and token providers.
4. Add `AddApiEndpoints()` so the Identity API endpoints are available.
5. Map `/identity` with `MapIdentityApi<TUser>()`.
6. Keep the antiforgery and authorization middleware order correct.
7. Verify that the web UI login still works after adding bearer auth.

## Good Patterns

- Keep the default challenge scheme unset so cookies and bearer tokens can coexist.
- Use a dedicated `/identity` route group for API endpoints.
- Test login, refresh, and protected endpoints separately from the browser UI.
- Document any client-specific base URLs for MAUI or mobile consumers.

## Gotchas

- **Never** set a default challenge scheme that blocks cookie and bearer coexistence.
- **Never** place antiforgery middleware before authentication and authorization in this flow.
- `AddBearerToken` must be configured before identity cookies if both are used.
- `.WithOpenApi()` is not needed for these endpoints in modern .NET 10 setups.

## Troubleshooting

| Symptom | Likely fix |
| --- | --- |
| `400 Bad Request` on login | Check middleware order: auth, authorization, then antiforgery |
| Cookie login stops working | Remove the default challenge scheme override |
| Bearer token is ignored | Verify `AddBearerToken` and endpoint mapping order |
| `/identity` returns 404 | Confirm `MapIdentityApi<TUser>()` is called after app build |

## References

- ASP.NET Core Identity API docs: https://learn.microsoft.com/aspnet/core/security/authentication/identity-api-authorization
- Bearer token auth docs: https://learn.microsoft.com/aspnet/core/security/authentication/identity/spa
- Related skill: `activating-identity-email-confirmation`
