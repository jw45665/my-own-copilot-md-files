---
name: adding-mailkit-email-sender
description: 'Add a production-ready MailKit email sender for .NET 10 Blazor and ASP.NET Core apps. Use when the user asks for SMTP email functionality, forms, notifications, MailKit/MimeKit setup, IEmailSender, or a reusable email service.'
license: Apache-2.0
---

# MailKit Email Sender for .NET 10

Create a reusable SMTP email service for .NET 10 applications. Prefer this skill when the task is about application emails, contact forms, notifications, password resets, or any feature that needs MailKit/MimeKit instead of a no-op sender.

## When to Use This Skill

- User asks to add or fix email sending in a Blazor or ASP.NET Core app
- User wants SMTP, MailKit, or MimeKit integration
- User needs a reusable `IEmailSender` implementation for notifications or forms
- User wants email configuration from appsettings, secrets, or environment variables

## Prerequisites

- .NET 10 project
- SMTP server credentials and a verified sender address
- `MailKit` and `MimeKit` packages

## Workflow

1. Create an `EmailConfiguration` model with host, port, username, from address, display name, SSL flag, and site name.
2. Pre-fill the SMTP server defaults in `appsettings.json` so no manual host/account completion is needed later.
3. Define a small `IEmailSender` abstraction with a single `SendEmailAsync` method.
4. Implement `EmailSender` with MailKit and MimeKit.
5. Inject `IOptions<EmailConfiguration>` and `ILogger<EmailSender>`.
6. In this repository, override `Email:Password` explicitly from the environment variable `PASSWORT_NOREPLY_SERVER-1` in `Program.cs`.
7. Build the HTML body in the service, not in UI components.
8. Register the sender as scoped in DI.
9. Keep passwords out of source control.

## Good Patterns

- Use `TextFormat.Html` for formatted mail bodies.
- Keep the sender address and SMTP username aligned with the service account.
- Wrap SMTP failures in a clear application exception and log the original exception.
- Enrich the subject line with the site name only if that value is present.
- In this repository, use `server-1.net` with `noreply@server-1.net` as the preconfigured SMTP account and read the password from `PASSWORT_NOREPLY_SERVER-1`.

## Gotchas

- **Never** hardcode SMTP passwords in `appsettings.json` or in code.
- **Never** forget the repository-specific override from `PASSWORT_NOREPLY_SERVER-1`, or SMTP authentication will fail on development and production systems.
- **Never** send mail directly from UI components when a service can own the SMTP logic.
- Some SMTP providers require `EnableSSL = true`, while others use STARTTLS on port 587; match the provider configuration.

## Troubleshooting

| Symptom | Likely fix |
| --- | --- |
| Authentication fails | Check username, password source, and sender address alignment |
| Mail arrives without HTML formatting | Ensure the body uses `MimeKit.Text.TextPart(TextFormat.Html)` |
| Connection timeout | Verify host, port, TLS mode, and outbound network access |
| Messages are rejected | Check SPF/DKIM, sender domain, and SMTP provider policy |

## References

- Related skill: `activating-identity-email-confirmation`
- MailKit documentation: https://github.com/jstedfast/MailKit
- MimeKit documentation: https://github.com/jstedfast/MimeKit
