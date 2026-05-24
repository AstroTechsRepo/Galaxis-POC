import { galaxisIdentity } from "@/styles/tokens";

/*
 * Galaxis POC — Footer
 * Reprend la signature et la tagline des slides.
 */
export function Footer() {
  return (
    <footer className="relative z-10 mt-auto border-t border-white/5 bg-space-deep/70 backdrop-blur-sm">
      <div className="mx-auto flex max-w-6xl flex-col items-start justify-between gap-3 px-6 py-5 text-xs text-white/60 md:flex-row md:items-center">
        <div className="flex items-center gap-3">
          <span className="galaxis-mono">{galaxisIdentity.tagline}</span>
        </div>
        <div className="text-right">
          <span>{galaxisIdentity.signature}</span>
        </div>
      </div>
    </footer>
  );
}
