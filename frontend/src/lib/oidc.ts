import { UserManager, WebStorageStateStore } from "oidc-client-ts";

/*
 * Galaxis POC v1.1 — Client OIDC (oidc-client-ts)
 *
 * Phase C : Keycloak n'est plus servi sous /iam du même origin, il a
 * sa propre URL HTTPS (caddy-iam) → VITE_KC_URL pointe vers Keycloak.
 *
 * - Flow Authorization Code + PKCE S256 (client public, pas de secret)
 * - redirect_uri = window.location.origin + /auth/callback
 *   → c'est l'origin du portail (https://localhost:9443 en démo),
 *   ce qui permet au même bundle de marcher derrière n'importe quel
 *   reverse proxy aval (cohérent avec le binding port loopback unique
 *   géré par le tunnel SSH du laptop).
 * - Tokens en sessionStorage (limite l'exposition XSS vs localStorage)
 */

// URL absolue de Keycloak (figée au build via Vite). En démo :
//   VITE_KC_URL=https://localhost:8443
const KC_URL = import.meta.env.VITE_KC_URL || "https://localhost:8443";

const KC_REALM = import.meta.env.VITE_KC_REALM || "galaxis";
const KC_CLIENT_ID = import.meta.env.VITE_KC_CLIENT_ID || "galaxis-portal";

// Origin du portail tel que vu par le navigateur (auto-détection runtime).
// En démo : https://localhost:9443 (forwardé par SSH vers app-caddy).
const PUBLIC_ORIGIN =
  typeof window !== "undefined" ? window.location.origin : "https://localhost:9443";

export const oidcAuthority = `${KC_URL}/realms/${KC_REALM}`;

export const userManager = new UserManager({
  authority: oidcAuthority,
  client_id: KC_CLIENT_ID,
  redirect_uri: `${PUBLIC_ORIGIN}/auth/callback`,
  post_logout_redirect_uri: `${PUBLIC_ORIGIN}/`,
  response_type: "code",
  scope: "openid profile email",
  loadUserInfo: false,
  automaticSilentRenew: true,
  // PKCE S256 activé par défaut depuis oidc-client-ts v3
  userStore:
    typeof window !== "undefined"
      ? new WebStorageStateStore({ store: window.sessionStorage })
      : undefined,
  stateStore:
    typeof window !== "undefined"
      ? new WebStorageStateStore({ store: window.sessionStorage })
      : undefined,
});

export async function login(): Promise<void> {
  await userManager.signinRedirect();
}

export async function completeLogin() {
  return userManager.signinRedirectCallback();
}

export async function logout(): Promise<void> {
  await userManager.signoutRedirect();
}

export async function getUser() {
  return userManager.getUser();
}
