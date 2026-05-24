/*
 * Galaxis POC — Design tokens
 *
 * Extraits du CSS des slides de soutenance (slide 01 — couverture).
 * Source unique de vérité utilisée par tailwind.config.ts et les composants
 * qui ont besoin de manipuler les couleurs en JS (par ex. SVG inline).
 */

export const galaxisColors = {
  violet: {
    dark: "#542669",
    mid: "#7B3E97",
    glow: "#A76EC8",
  },
  blue: {
    dark: "#127DC2",
    light: "#07A9DD",
    glow: "#60D5FF",
  },
  space: {
    black: "#07060D",
    deep: "#0D0B1A",
    card: "#14112A",
    hover: "#1A1638",
  },
} as const;

export const galaxisGradient =
  "linear-gradient(135deg, #07A9DD 0%, #60D5FF 25%, #A76EC8 60%, #7B3E97 100%)";

export const galaxisFonts = {
  display: "'Space Grotesk', sans-serif",
  body: "Inter, sans-serif",
  mono: "'JetBrains Mono', monospace",
} as const;

export const galaxisIdentity = {
  productName: "Galaxis",
  tagline: "One core. Infinite orbits.",
  subtitle: "L'orchestrateur souverain de votre écosystème open source",
  publisher: "AstroTechs",
  signature: "Lucas PEREZ · ESGI 2 · Campus Éductive · 2025 / 2026",
} as const;
