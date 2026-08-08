/**
 * AuthCore API Client – ESM-Modul für Browser und Node.js
 *
 * Verwendung:
 *   import * as api from './js/authcore-api.js';
 *   await api.login('user@example.com', 'Password123!');
 *   const profile = await api.getProfile();
 *
 * Anpassen: API_BASE auf den tatsächlichen Server-URL setzen.
 */

// ── Konfiguration ─────────────────────────────────────────────────────────────
const API_BASE = 'http://localhost:5101'; // HTTPS: https://localhost:7157

// ── Token-Verwaltung (sessionStorage – gültig bis Tab geschlossen) ────────────

export function saveTokens(accessToken, refreshToken) {
    sessionStorage.setItem('authcore_access', accessToken);
    sessionStorage.setItem('authcore_refresh', refreshToken);
}

export function getAccessToken() {
    return sessionStorage.getItem('authcore_access');
}

export function getRefreshToken() {
    return sessionStorage.getItem('authcore_refresh');
}

export function clearTokens() {
    sessionStorage.removeItem('authcore_access');
    sessionStorage.removeItem('authcore_refresh');
}

export function isLoggedIn() {
    return !!getAccessToken();
}

// ── Interne Hilfsfunktion: Fetch mit Bearer-Token + Auto-Refresh ──────────────

async function apiFetch(path, options = {}) {
    const token = getAccessToken();
    const headers = {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
        ...(options.headers ?? {})
    };

    let response = await fetch(`${API_BASE}${path}`, { ...options, headers });

    if (response.status === 401) {
        const refreshed = await tryRefreshToken();
        if (refreshed) {
            headers['Authorization'] = `Bearer ${getAccessToken()}`;
            response = await fetch(`${API_BASE}${path}`, { ...options, headers });
        }
    }

    return response;
}

// ── Identity-Endpunkte ────────────────────────────────────────────────────────

/**
 * Meldet einen Benutzer an und speichert die Tokens.
 * @returns {Promise<{tokenType, accessToken, expiresIn, refreshToken}>}
 */
export async function login(email, password) {
    const response = await fetch(
        `${API_BASE}/identity/login?useCookies=false&useSessionCookies=false`,
        {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        }
    );
    if (!response.ok) {
        const err = await response.json().catch(() => ({}));
        throw new Error(err.detail ?? `Login fehlgeschlagen (${response.status})`);
    }
    const data = await response.json();
    saveTokens(data.accessToken, data.refreshToken);
    return data;
}

/**
 * Erneuert den Access Token mit dem gespeicherten Refresh Token.
 * @returns {Promise<boolean>}
 */
export async function tryRefreshToken() {
    const refresh = getRefreshToken();
    if (!refresh) return false;
    const response = await fetch(`${API_BASE}/identity/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: refresh })
    });
    if (!response.ok) { clearTokens(); return false; }
    const data = await response.json();
    saveTokens(data.accessToken, data.refreshToken);
    return true;
}

/**
 * Registriert einen neuen Benutzer.
 */
export async function register(email, password) {
    const response = await fetch(`${API_BASE}/identity/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
    });
    return response.ok;
}

/** Leert Tokens und leitet zur Login-Seite weiter. */
export function logout(loginPage = 'login.html') {
    clearTokens();
    window.location.href = loginPage;
}

// ── Profil-Endpunkte ──────────────────────────────────────────────────────────

/**
 * Gibt das eigene Profil oder das Profil eines anderen Nutzers zurück.
 * @param {string|null} userId - null = eigenes Profil
 */
export async function getProfile(userId = null) {
    const path = userId ? `/api/v1/profile/${userId}` : '/api/v1/profile';
    const response = await apiFetch(path);
    if (!response.ok) throw new Error(`Profil konnte nicht geladen werden (${response.status})`);
    const result = await response.json();
    return result.data ?? result;
}

/**
 * Aktualisiert das eigene Profil.
 * @param {object} profileData - Felder gemäß UpdateProfileDto
 * Pflichtfelder: publicUsername, displayName
 */
export async function updateProfile(profileData) {
    const response = await apiFetch('/api/v1/profile', {
        method: 'PUT',
        body: JSON.stringify(profileData)
    });
    if (!response.ok) {
        const err = await response.json().catch(() => ({}));
        throw new Error(err.message ?? `Profil-Update fehlgeschlagen (${response.status})`);
    }
    return true;
}

/**
 * Lädt ein Profilbild hoch (multipart/form-data).
 * Keinen Content-Type-Header setzen – Browser setzt Boundary automatisch.
 */
export async function uploadProfilePicture(file) {
    const formData = new FormData();
    formData.append('file', file);
    const token = getAccessToken();
    const response = await fetch(`${API_BASE}/api/v1/profile/picture`, {
        method: 'POST',
        headers: token ? { 'Authorization': `Bearer ${token}` } : {},
        body: formData
    });
    return response.ok;
}

/**
 * Prüft die Verfügbarkeit eines Benutzernamens (kein Auth erforderlich).
 * @returns {Promise<{available: boolean, message: string|null}>}
 */
export async function checkUsernameAvailability(username) {
    const response = await fetch(
        `${API_BASE}/api/v1/profile/check-username/${encodeURIComponent(username)}`
    );
    if (!response.ok) throw new Error(`Prüfung fehlgeschlagen (${response.status})`);
    return await response.json();
}

// ── Autocomplete-Endpunkte ────────────────────────────────────────────────────

/**
 * Liefert Städte-Vorschläge (min. 2 Zeichen Query).
 * @returns {Promise<string[]>}
 */
export async function getCities(query) {
    if (!query || query.length < 2) return [];
    const response = await fetch(
        `${API_BASE}/api/v1/autocomplete/cities?query=${encodeURIComponent(query)}`
    );
    if (!response.ok) return [];
    return await response.json();
}

/**
 * Gibt alle verfügbaren Länder zurück.
 * @returns {Promise<Array<{name: string, code: string}>>}
 */
export async function getCountries() {
    const response = await fetch(`${API_BASE}/api/v1/autocomplete/countries`);
    if (!response.ok) return [];
    return await response.json();
}
