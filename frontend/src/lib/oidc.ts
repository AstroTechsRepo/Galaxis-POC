import { UserManager, WebStorageStateStore } from "oidc-client-ts";

const KC_URL = import.meta.env.VITE_KC_URL || "http://localhost:8080";

const KC_REALM = import.meta.env.VITE_KC_REALM || "galaxis";
const KC_CLIENT_ID = import.meta.env.VITE_KC_CLIENT_ID || "galaxis-portal";

const PUBLIC_ORIGIN =
  typeof window !== "undefined" ? window.location.origin : "http://localhost:9080";

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
