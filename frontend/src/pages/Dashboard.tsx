import { useEffect, useState } from "react";
import { Navigate } from "react-router-dom";
import { BrickCard } from "@/components/BrickCard";
import { ClaimsTable } from "@/components/ClaimsTable";
import { useAuth } from "@/hooks/useAuth";
import { fetchMe } from "@/lib/api";
import type { MeResponse } from "@/types/auth";

/*
 * Galaxis POC — Dashboard
 *
 * Vue après login. Cartes des briques disponibles (Vaultwarden, Nextcloud)
 * + profil utilisateur côté backend + claims du JWT.
 */
export function Dashboard() {
  const { status, token, user } = useAuth();
  const [me, setMe] = useState<MeResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (status !== "authenticated" || !token) return;
    let cancelled = false;
    void (async () => {
      try {
        const data = await fetchMe(token);
        if (!cancelled) setMe(data);
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

  const displayName =
    me?.user?.first_name ||
    user?.profile?.given_name ||
    user?.profile?.preferred_username ||
    "Lucas";

  return (
    <main className="relative mx-auto w-full max-w-6xl flex-1 px-6 py-10">
      <header className="mb-10 flex flex-col gap-2">
        <span className="galaxis-mono text-xs uppercase tracking-widest text-blue-glow">
          Dashboard
        </span>
        <h1 className="font-display text-3xl font-semibold md:text-4xl">
          Bienvenue,&nbsp;
          <span className="galaxis-text-gradient">{displayName}</span>
        </h1>
        <p className="text-white/60">
          Vos briques sont prêtes. Un seul login, plusieurs outils.
        </p>
      </header>

      {/* Briques */}
      <section aria-labelledby="bricks-title" className="mb-12">
        <h2
          id="bricks-title"
          className="mb-4 font-display text-sm font-semibold uppercase tracking-wider text-white/70"
        >
          Vos briques
        </h2>
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          <BrickCard
            title="Vaultwarden"
            description="Coffre-fort de mots de passe d'équipe. Stockez, partagez, ne perdez plus rien."
            href={`http://${window.location.hostname}:10180/`}
            icon={<VaultIcon />}
          />
          <BrickCard
            title="Nextcloud"
            description="Drive collaboratif. Fichiers, dossiers partagés, calendrier d'équipe."
            href={`http://${window.location.hostname}:11180/`}
            icon={<CloudIcon />}
          />
          <BrickCard
            title="VPN souverain"
            description="Accès distant sécurisé à vos ressources internes. Prévu dans la prochaine version."
            href="#"
            icon={<VpnIcon />}
            status="soon"
            external={false}
          />
        </div>
      </section>

      {/* Claims */}
      <section aria-labelledby="claims-title">
        <h2
          id="claims-title"
          className="mb-4 font-display text-sm font-semibold uppercase tracking-wider text-white/70"
        >
          Identité &amp; claims (lecture serveur)
        </h2>
        {error && (
          <div className="rounded-lg border border-red-300/30 bg-red-500/10 px-4 py-3 text-sm text-red-200 flex items-center justify-between">
            <span>Erreur en appelant <code>/api/me</code> : {error}</span>
            <button
              onClick={() => window.location.reload()}
              className="ml-4 rounded bg-white/10 px-3 py-1 text-xs font-medium text-white hover:bg-white/20"
            >
              Réessayer
            </button>
          </div>
        )}
        {me && <ClaimsTable claims={me.claims} />}
      </section>
    </main>
  );
}

function VaultIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" width="22" height="22" aria-hidden>
      <path
        d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6l8-4z"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path d="M12 8v4l3 2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}
function CloudIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" width="22" height="22" aria-hidden>
      <path
        d="M7 18a4 4 0 010-8 5 5 0 019.6-1A4 4 0 0117 18H7z"
        stroke="currentColor"
        strokeWidth="1.5"
      />
    </svg>
  );
}
function VpnIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" width="22" height="22" aria-hidden>
      <rect x="3" y="10" width="18" height="11" rx="2" stroke="currentColor" strokeWidth="1.5" />
      <path d="M7 10V7a5 5 0 0110 0v3" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}
