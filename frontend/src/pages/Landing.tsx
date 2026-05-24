import { LoginButton } from "@/components/LoginButton";
import { galaxisIdentity } from "@/styles/tokens";

/*
 * Galaxis POC — Landing
 *
 * Page d'accueil reprise des slides de couverture :
 *  - Wordmark géant en gradient
 *  - Tagline en mono violet
 *  - Sous-titre
 *  - CTA "Se connecter"
 */
export function Landing() {
  return (
    <main className="relative flex flex-1 items-center justify-center px-6 py-16">
      <div className="relative z-10 mx-auto max-w-3xl text-center">
        <h1 className="font-display text-7xl font-bold leading-none tracking-tight md:text-9xl galaxis-text-gradient">
          {galaxisIdentity.productName}
        </h1>

        <p className="mt-6 font-display text-sm uppercase tracking-[0.35em] text-violet-glow">
          {galaxisIdentity.tagline}
        </p>

        <p className="mt-8 text-lg text-white/70 md:text-xl">{galaxisIdentity.subtitle}</p>

        <div className="mt-12 flex flex-col items-center gap-4">
          <LoginButton label="Se connecter avec Keycloak" className="text-base" />
          <p className="galaxis-mono text-xs text-white/40">
            Authentification déléguée — flow OIDC + PKCE
          </p>
        </div>

        <div className="mt-16 grid grid-cols-1 gap-4 text-left md:grid-cols-3">
          <Feature
            title="Identité centralisée"
            body="Annuaire et comptes gérés une seule fois, partagés entre toutes vos briques."
          />
          <Feature
            title="Briques modulaires"
            body="Mots de passe, drive, et tout ce que vous ajouterez ensuite. Une carte de plus dans le portail."
          />
          <Feature
            title="Souverain et open source"
            body="Vous hébergez. Vous décidez. Vous reprenez la main sur vos outils."
          />
        </div>
      </div>
    </main>
  );
}

function Feature({ title, body }: { title: string; body: string }) {
  return (
    <div className="galaxis-card galaxis-card-hover rounded-2xl p-5">
      <h3 className="font-display text-base font-semibold text-white">{title}</h3>
      <p className="mt-2 text-sm text-white/70">{body}</p>
    </div>
  );
}
