// AuthCore API – DTOs für externe Clients
// HINWEIS: Falls AuthCore.Shared als Projektreferenz verfügbar ist,
//          NICHT diese Datei kopieren – stattdessen AuthCore.Shared.DTOs direkt nutzen.
//
// Namespace anpassen: YourNamespace.Services → z.B. MeineApp.Services

namespace YourNamespace.Services;

// ── Identity ──────────────────────────────────────────────────────────────────

public record LoginResponse(
    string TokenType,
    string AccessToken,
    int ExpiresIn,
    string RefreshToken);

// ── Profil ────────────────────────────────────────────────────────────────────

/// <summary>
/// GET /api/v1/profile  oder  GET /api/v1/profile/{userId}
/// Private Felder (Email, PhoneNumber, Address, PostalCode) werden nur beim eigenen Profil befüllt.
/// </summary>
public record UserProfileDto(
    string UserId,
    string PublicUsername,
    string DisplayName,
    string? FirstName,
    string? LastName,
    string? Email,              // privat – nur eigenes Profil
    string? PhoneNumber,        // privat – nur eigenes Profil
    DateTime? DateOfBirth,
    string? Bio,
    string? ProfilePictureUrl,
    int Gender,                 // 0=Unspecified 1=Male 2=Female 3=Other
    string? CityName,
    string? Country,            // ISO 3166-1 Alpha-2 (z.B. "DE")
    string? Address,            // privat – nur eigenes Profil
    string? PostalCode,         // privat – nur eigenes Profil
    string? TimeZone,
    string? PreferredLanguage,  // ISO 639-1 (z.B. "de")
    string? Website,
    Dictionary<string, string>? SocialLinks,
    int ProfileVisibility,      // 0=Public 1=FriendsOnly 2=Private
    int UserRole,               // 0=Guest 1=RegisteredFree 2=RegisteredPaid 3=Moderator 4=Admin
    bool IsProfilePublic,
    DateTime CreatedAt,
    DateTime? LastActiveAt,
    int ProfileCompleteness,    // 0-100 %
    bool AllowMessagesFromStrangers,
    bool EmailNotificationsEnabled);

/// <summary>
/// PUT /api/v1/profile
/// PublicUsername und DisplayName sind Pflichtfelder.
/// </summary>
public record UpdateProfileDto(
    string PublicUsername,              // REQUIRED · 3-30 Zeichen · [a-zA-Z0-9_\- ]
    string DisplayName,                 // REQUIRED · 3-50 Zeichen
    string? FirstName,
    string? LastName,
    string? PhoneNumber,
    DateTime? DateOfBirth,
    string? Bio,                        // max. 500 Zeichen
    int Gender,                         // 0=Unspecified 1=Male 2=Female 3=Other
    string? CityName,
    string? Country,                    // ISO 3166-1 Alpha-2 · Großbuchstaben
    string? Address,
    string? PostalCode,
    string? TimeZone,
    string? PreferredLanguage,          // ISO 639-1 · Kleinbuchstaben
    string? Website,
    Dictionary<string, string>? SocialLinks,
    int ProfileVisibility,              // 0=Public 1=FriendsOnly 2=Private
    bool AllowMessagesFromStrangers,
    bool EmailNotificationsEnabled);

/// <summary>
/// GET /api/v1/profile/check-username/{username}
/// </summary>
public record UsernameAvailabilityDto(bool Available, string? Message);

// ── Autocomplete ──────────────────────────────────────────────────────────────

/// <summary>GET /api/v1/autocomplete/countries</summary>
public record CountryDto(string Name, string Code);

// ── Shared Response-Wrapper ───────────────────────────────────────────────────

public record ApiResponse<T>(bool Success, T? Data, string? Message, List<string> Errors);
