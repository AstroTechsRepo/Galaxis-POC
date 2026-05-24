import type { MeResponse } from "@/types/auth";

/*
 * Galaxis POC v1.1 — Client API minimaliste.
 *
 * Le backend Laravel est sous /api sur le même origin que le portail
 * (app-caddy fait le routage handle_path /api/* → php_fastcgi). On
 * peut donc rester en chemin relatif `/api` côté JS pour bénéficier
 * de la cohérence d'origine (pas de CORS preflight, cookies same-site).
 *
 * VITE_API_URL n'est utilisé que si on souhaite explicitement pointer
 * vers une URL absolue (ex : front et back déployés séparément).
 */
const API_BASE =
  import.meta.env.VITE_API_URL ||
  import.meta.env.VITE_API_BASE ||
  "/api";

export interface AuditEntry {
  id: number;
  user_id: number | null;
  event: string;
  ip: string | null;
  user_agent: string | null;
  payload: Record<string, unknown> | null;
  created_at: string;
}

async function authed(path: string, token: string | null): Promise<Response> {
  const headers: HeadersInit = { Accept: "application/json" };
  if (token) headers.Authorization = `Bearer ${token}`;
  return fetch(`${API_BASE}${path}`, { headers });
}

export async function fetchMe(token: string | null): Promise<MeResponse> {
  const resp = await authed("/me", token);
  if (!resp.ok) {
    throw new Error(`/api/me failed: ${resp.status}`);
  }
  return (await resp.json()) as MeResponse;
}

export async function fetchAudit(token: string | null, limit = 50): Promise<AuditEntry[]> {
  const resp = await authed(`/audit?limit=${limit}`, token);
  if (!resp.ok) {
    throw new Error(`/api/audit failed: ${resp.status}`);
  }
  const data = (await resp.json()) as { logs: AuditEntry[] };
  return data.logs;
}

export async function fetchHealth(): Promise<{ status: string; checks: Record<string, unknown> }> {
  const resp = await fetch(`${API_BASE}/health`, { headers: { Accept: "application/json" } });
  return resp.json();
}
