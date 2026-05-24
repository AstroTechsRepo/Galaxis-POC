import { Navigate } from "react-router-dom";
import { useEffect, useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import { fetchAudit, type AuditEntry } from "@/lib/api";

/*
 * Galaxis POC — Profile
 *
 * Affiche les infos du user en base + un extrait du journal d'audit
 * (derniers événements d'auth).
 */
export function Profile() {
  const { status, token, user } = useAuth();
  const [logs, setLogs] = useState<AuditEntry[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (status !== "authenticated" || !token) return;
    let cancelled = false;
    void (async () => {
      try {
        const data = await fetchAudit(token, 25);
        if (!cancelled) setLogs(data);
      } catch (e) {
        if (!cancelled) setError((e as Error).message);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [status, token]);

  if (status === "loading") {
    return (
      <main className="flex flex-1 items-center justify-center">
        <p className="galaxis-mono text-sm text-white/60">Chargement…</p>
      </main>
    );
  }
  if (status === "anonymous") return <Navigate to="/" replace />;

  return (
    <main className="mx-auto w-full max-w-5xl flex-1 px-6 py-10">
      <header className="mb-8">
        <span className="galaxis-mono text-xs uppercase tracking-widest text-blue-glow">
          Profil
        </span>
        <h1 className="mt-1 font-display text-3xl font-semibold">
          {user?.profile?.name ?? user?.profile?.preferred_username}
        </h1>
        <p className="text-white/60">{user?.profile?.email}</p>
      </header>

      <section className="galaxis-card mb-8 rounded-2xl p-5">
        <h2 className="mb-4 font-display text-sm font-semibold uppercase tracking-wider text-white/70">
          Session OIDC
        </h2>
        <dl className="grid grid-cols-1 gap-3 md:grid-cols-2">
          <Item label="Subject (sub)" value={<code className="galaxis-mono">{user?.profile?.sub}</code>} />
          <Item label="Authorized party (azp)" value={user?.profile?.azp ?? "—"} />
          <Item
            label="Token expire à"
            value={user?.expires_at ? new Date(user.expires_at * 1000).toLocaleString("fr-FR") : "—"}
          />
          <Item label="Scope" value={<code className="galaxis-mono text-xs">{user?.scope}</code>} />
        </dl>
      </section>

      <section>
        <h2 className="mb-4 font-display text-sm font-semibold uppercase tracking-wider text-white/70">
          Activité d'authentification (audit log)
        </h2>
        {error && (
          <p className="rounded-lg border border-red-300/30 bg-red-500/10 px-4 py-3 text-sm text-red-200">
            Impossible de charger l'audit : {error}
          </p>
        )}
        <div className="galaxis-card overflow-hidden rounded-2xl">
          <table className="w-full text-sm">
            <thead className="bg-space-card/60 text-left text-xs uppercase tracking-wider text-white/60">
              <tr>
                <th className="px-4 py-3">Quand</th>
                <th className="px-4 py-3">Événement</th>
                <th className="px-4 py-3">IP</th>
              </tr>
            </thead>
            <tbody>
              {logs.length === 0 && (
                <tr>
                  <td className="px-4 py-3 text-white/50" colSpan={3}>
                    Aucun événement (pour l'instant).
                  </td>
                </tr>
              )}
              {logs.map((l) => (
                <tr key={l.id} className="border-t border-white/5">
                  <td className="px-4 py-2 text-white/80">
                    {new Date(l.created_at).toLocaleString("fr-FR")}
                  </td>
                  <td className="px-4 py-2">
                    <span
                      className={`galaxis-mono rounded-md px-2 py-0.5 text-xs ${
                        l.event === "auth.success"
                          ? "bg-blue-light/10 text-blue-glow"
                          : "bg-violet-mid/15 text-violet-glow"
                      }`}
                    >
                      {l.event}
                    </span>
                  </td>
                  <td className="px-4 py-2 text-white/60">{l.ip ?? "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </main>
  );
}

function Item({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div>
      <dt className="text-xs uppercase tracking-wider text-white/50">{label}</dt>
      <dd className="mt-1 break-all text-sm text-white/90">{value}</dd>
    </div>
  );
}
