/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** URL absolue de Keycloak (ex: http://localhost:8080) */
  readonly VITE_KC_URL: string;
  /** URL absolue OU chemin relatif de l'API Laravel (ex: /api) — Phase C */
  readonly VITE_API_URL: string;
  readonly VITE_KC_REALM: string;
  readonly VITE_KC_CLIENT_ID: string;

  // Legacy Phase A/B (gardés pour compat tests existants)
  readonly VITE_KC_BASE?: string;
  readonly VITE_API_BASE?: string;
  readonly VITE_PUBLIC_ORIGIN?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
