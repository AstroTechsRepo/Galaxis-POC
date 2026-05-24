/*
 * Galaxis POC — BrickCard
 *
 * Une « brique » sur le dashboard. Affiche une icône, un titre, une
 * description et un lien d'accès. Visuellement glassmorphism, bord
 * dégradé au hover.
 */

export interface BrickCardProps {
  title: string;
  description: string;
  href: string;
  icon: React.ReactNode;
  status?: "available" | "soon";
  external?: boolean;
}

export function BrickCard({
  title,
  description,
  href,
  icon,
  status = "available",
  external = true,
}: BrickCardProps) {
  const isAvailable = status === "available";
  return (
    <a
      href={href}
      target={external ? "_blank" : undefined}
      rel={external ? "noopener noreferrer" : undefined}
      aria-disabled={!isAvailable}
      onClick={(e) => {
        if (!isAvailable) e.preventDefault();
      }}
      className={`galaxis-card galaxis-card-hover relative block rounded-2xl p-5 ${
        isAvailable ? "" : "cursor-not-allowed opacity-60"
      }`}
      data-testid={`brick-${title.toLowerCase()}`}
    >
      <div className="flex items-start gap-4">
        <div className="grid h-12 w-12 place-items-center rounded-xl bg-gradient-to-br from-blue-light/30 to-violet-mid/30 text-blue-glow">
          {icon}
        </div>
        <div className="min-w-0 flex-1">
          <div className="flex items-center justify-between gap-2">
            <h3 className="font-display text-lg font-semibold text-white">{title}</h3>
            <span className="galaxis-mono text-[10px] uppercase tracking-widest">
              {isAvailable ? "disponible" : "à venir"}
            </span>
          </div>
          <p className="mt-1 text-sm text-white/70">{description}</p>
          <div className="mt-3 flex items-center gap-2 text-sm text-blue-glow">
            {isAvailable ? "Ouvrir" : "Bientôt"}
            <span aria-hidden>→</span>
          </div>
        </div>
      </div>
    </a>
  );
}
