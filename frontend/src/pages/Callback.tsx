import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { completeLogin } from "@/lib/oidc";

/*
 * Galaxis POC — Callback
 *
 * Reçoit le `code` Keycloak, l'échange contre les tokens via
 * oidc-client-ts (qui vérifie le code_verifier PKCE),
 * puis redirige vers /dashboard.
 */
export function Callback() {
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      try {
        await completeLogin();
        if (!cancelled) navigate("/dashboard", { replace: true });
      } catch (e) {
        if (!cancelled) setError((e as Error).message);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [navigate]);

  return (
    <main className="flex flex-1 items-center justify-center p-8">
      <div className="galaxis-card max-w-md rounded-2xl p-8 text-center" data-testid="callback">
        {error ? (
          <>
            <h2 className="font-display text-xl font-semibold text-red-300">
              Échec de la connexion
            </h2>
            <p className="mt-3 text-sm text-white/70">{error}</p>
            <button
              type="button"
              onClick={() => navigate("/", { replace: true })}
              className="mt-6 rounded-md border border-white/10 px-4 py-2 text-sm hover:border-blue-glow/50"
            >
              Revenir à l'accueil
            </button>
          </>
        ) : (
          <>
            <h2 className="font-display text-xl font-semibold">Authentification en cours…</h2>
            <p className="mt-3 text-sm text-white/60">
              Échange du code d'autorisation contre un token JWT.
            </p>
            <div className="mt-6 h-1 w-full overflow-hidden rounded-full bg-space-hover">
              <div className="h-full w-1/3 animate-pulse-glow bg-galaxis-gradient" />
            </div>
          </>
        )}
      </div>
    </main>
  );
}
