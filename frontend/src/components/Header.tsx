import { Link, useLocation } from "react-router-dom";
import { Logo } from "@/components/Logo";
import { useAuth } from "@/hooks/useAuth";

/*
 * Galaxis POC — Header
 * Affiche le wordmark, l'état d'auth, et un bouton login/logout.
 */
export function Header() {
  const { status, user, login, logout } = useAuth();
  const location = useLocation();
  const onLanding = location.pathname === "/";

  return (
    <header className="relative z-20 border-b border-white/5 bg-space-deep/70 backdrop-blur-sm">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <Link to="/" aria-label="Galaxis - retour à l'accueil">
          <Logo size={28} />
        </Link>
        <nav className="flex items-center gap-4 text-sm text-white/70">
          {status === "authenticated" && (
            <Link
              to="/dashboard"
              className="rounded-md px-3 py-1.5 transition hover:bg-space-hover/60 hover:text-white"
            >
              Dashboard
            </Link>
          )}
          {status === "authenticated" && (
            <Link
              to="/profile"
              className="rounded-md px-3 py-1.5 transition hover:bg-space-hover/60 hover:text-white"
            >
              Profil
            </Link>
          )}
          {status === "loading" && (
            <span className="galaxis-mono text-xs">Chargement…</span>
          )}
          {status === "anonymous" && onLanding && (
            <button
              type="button"
              onClick={() => void login()}
              className="galaxis-btn-gradient text-sm"
            >
              Se connecter
            </button>
          )}
          {status === "authenticated" && (
            <>
              <span className="hidden text-xs text-white/60 md:inline">
                {user?.profile?.preferred_username ?? user?.profile?.email}
              </span>
              <button
                type="button"
                onClick={() => void logout()}
                className="rounded-md border border-white/10 px-3 py-1.5 text-sm transition hover:border-blue-glow/40 hover:text-blue-glow"
              >
                Déconnexion
              </button>
            </>
          )}
        </nav>
      </div>
    </header>
  );
}
