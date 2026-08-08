---
name: activating-identity-email-confirmation
description: 'Activate ASP.NET Core Identity email confirmation and password reset in .NET 10 apps. Use when the user asks to replace a no-op email sender, require confirmed accounts, wire IdentityEmailSender, or add confirmation and reset flows.'
license: Apache-2.0
---

# Identity Email Confirmation

Activate confirmed-account sign-in for ASP.NET Core Identity and route confirmation and password-reset messages through the app email service. Use this skill when the project already has Identity and needs a real email flow instead of a dummy sender.

## When to Use This Skill

- User wants email confirmation for registration
- User wants password-reset emails for Identity
- User wants to replace `IdentityNoOpEmailSender`
- User wants `RequireConfirmedAccount = true`
- User needs an adapter between Identity and a reusable email service

## Prerequisites

- ASP.NET Core Identity is already installed
- A working email sender exists in the app
- `IEmailSender<TUser>` is available for the Identity user type

## Workflow

1. Turn on confirmed-account sign-in in the Identity options.
2. Register an `IdentityEmailSender` adapter as a singleton.
3. Resolve the reusable email sender through `IServiceScopeFactory` inside the adapter.
4. Implement confirmation-link and password-reset methods by delegating to the mail service.
5. Remove any no-op or placeholder Identity sender registration.
6. Verify that registration now requires confirmation before login succeeds.

## Good Patterns

- Keep `IdentityEmailSender` thin; let the MailKit service handle formatting and SMTP.
- Use `IServiceScopeFactory` because the adapter is registered as a singleton.
- Treat the framework-generated confirmation and reset links as opaque values; forward them unchanged.

## Gotchas

- **Never** inject a scoped email sender directly into the Identity adapter if the adapter itself is a singleton.
- **Never** forget `AddDefaultTokenProviders()` or the confirmation/reset tokens will not work.
- Enabling confirmed accounts changes the expected login flow; unconfirmed users should fail to sign in until they confirm their email.

## Troubleshooting

| Symptom | Likely fix |
| --- | --- |
| `No service for type IEmailSender<T>` | Register the adapter with the correct generic user type |
| `Cannot resolve scoped service from root provider` | Resolve the email service through `IServiceScopeFactory` |
| Confirmation link arrives but login still fails | Verify the token flow, user state, and `RequireConfirmedAccount` setting |
| Password reset email is missing | Check that the adapter implements both link and code methods as needed |

## References

- Related skill: `adding-mailkit-email-sender`
- ASP.NET Core Identity email confirmation docs: https://learn.microsoft.com/aspnet/core/security/authentication/identity-confirm-email
- Identity API/token docs: https://learn.microsoft.com/aspnet/core/security/authentication/identity
