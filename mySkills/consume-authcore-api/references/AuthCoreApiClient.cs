using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace YourNamespace.Services;

/// <summary>
/// HTTP-Client für die AuthCore Identity API.
/// Registrierung (MauiProgram.cs / Program.cs):
///   builder.Services.AddHttpClient&lt;AuthCoreApiClient&gt;(c => c.BaseAddress = new Uri("http://localhost:5101/"));
/// </summary>
public class AuthCoreApiClient
{
    private readonly HttpClient _http;
    private string? _accessToken;
    private string? _refreshToken;

    public bool IsLoggedIn => _accessToken is not null;

    public AuthCoreApiClient(HttpClient http) => _http = http;

    // ── Identity ──────────────────────────────────────────────────────────────

    public async Task<LoginResponse?> LoginAsync(string email, string password)
    {
        var response = await _http.PostAsJsonAsync(
            "identity/login?useCookies=false&useSessionCookies=false",
            new { email, password });

        if (!response.IsSuccessStatusCode) return null;

        var result = await response.Content.ReadFromJsonAsync<LoginResponse>();
        if (result is not null) ApplyTokens(result.AccessToken, result.RefreshToken);
        return result;
    }

    public async Task<bool> RefreshAsync()
    {
        if (_refreshToken is null) return false;

        var response = await _http.PostAsJsonAsync("identity/refresh",
            new { refreshToken = _refreshToken });

        if (!response.IsSuccessStatusCode) { ClearTokens(); return false; }

        var result = await response.Content.ReadFromJsonAsync<LoginResponse>();
        if (result is null) return false;
        ApplyTokens(result.AccessToken, result.RefreshToken);
        return true;
    }

    public void Logout() => ClearTokens();

    // ── Profil ────────────────────────────────────────────────────────────────

    public Task<UserProfileDto?> GetProfileAsync(string? userId = null)
    {
        var path = userId is null ? "api/v1/profile" : $"api/v1/profile/{userId}";
        return SendWithRetryAsync<UserProfileDto>(path);
    }

    public async Task<bool> UpdateProfileAsync(UpdateProfileDto dto)
    {
        var response = await SendWithRetryAsync(() => _http.PutAsJsonAsync("api/v1/profile", dto));
        return response.IsSuccessStatusCode;
    }

    public async Task<bool> UploadProfilePictureAsync(Stream stream, string fileName)
    {
        using var content = new MultipartFormDataContent();
        content.Add(new StreamContent(stream), "file", fileName);
        var response = await SendWithRetryAsync(() => _http.PostAsync("api/v1/profile/picture", content));
        return response.IsSuccessStatusCode;
    }

    /// <summary>Prüft Benutzernamen-Verfügbarkeit – kein Auth erforderlich.</summary>
    public async Task<UsernameAvailabilityDto?> CheckUsernameAsync(string username)
    {
        var response = await _http.GetAsync($"api/v1/profile/check-username/{Uri.EscapeDataString(username)}");
        if (!response.IsSuccessStatusCode) return null;
        return await response.Content.ReadFromJsonAsync<UsernameAvailabilityDto>();
    }

    // ── Autocomplete ──────────────────────────────────────────────────────────

    public async Task<List<string>> GetCitiesAsync(string query)
    {
        if (string.IsNullOrWhiteSpace(query) || query.Length < 2) return [];
        var response = await _http.GetAsync($"api/v1/autocomplete/cities?query={Uri.EscapeDataString(query)}");
        if (!response.IsSuccessStatusCode) return [];
        return await response.Content.ReadFromJsonAsync<List<string>>() ?? [];
    }

    public async Task<List<CountryDto>> GetCountriesAsync()
    {
        var response = await _http.GetAsync("api/v1/autocomplete/countries");
        if (!response.IsSuccessStatusCode) return [];
        return await response.Content.ReadFromJsonAsync<List<CountryDto>>() ?? [];
    }

    // ── Interne Hilfsmethoden ─────────────────────────────────────────────────

    private void ApplyTokens(string access, string refresh)
    {
        _accessToken = access;
        _refreshToken = refresh;
        _http.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", _accessToken);
    }

    private void ClearTokens()
    {
        _accessToken = null;
        _refreshToken = null;
        _http.DefaultRequestHeaders.Authorization = null;
    }

    private async Task<T?> SendWithRetryAsync<T>(string path)
    {
        var response = await SendWithRetryAsync(() => _http.GetAsync(path));
        if (!response.IsSuccessStatusCode) return default;
        var result = await response.Content.ReadFromJsonAsync<ApiResponse<T>>();
        return result is not null ? result.Data : default;
    }

    private async Task<HttpResponseMessage> SendWithRetryAsync(
        Func<Task<HttpResponseMessage>> request)
    {
        var response = await request();
        if (response.StatusCode == HttpStatusCode.Unauthorized)
        {
            if (await RefreshAsync())
                response = await request();
        }
        return response;
    }
}
