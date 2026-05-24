/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE: string;
  readonly VITE_KC_BASE: string;
  readonly VITE_KC_REALM: string;
  readonly VITE_KC_CLIENT_ID: string;
  readonly VITE_PUBLIC_ORIGIN: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
