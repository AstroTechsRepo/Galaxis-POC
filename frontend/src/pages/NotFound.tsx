import { Link } from "react-router-dom";

export function NotFound() {
  return (
    <main className="flex flex-1 flex-col items-center justify-center px-6 py-16 text-center">
      <h1 className="font-display text-8xl font-bold galaxis-text-gradient">404</h1>
      <p className="mt-4 text-lg text-white/70">
        Cette orbite n'existe pas… ou plus.
      </p>
      <Link to="/" className="galaxis-btn-gradient mt-8 inline-block text-sm">
        Retour à l'accueil
      </Link>
    </main>
  );
}
