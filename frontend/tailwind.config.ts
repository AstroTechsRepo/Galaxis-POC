import type { Config } from "tailwindcss";

/*
 * Galaxis POC — Tailwind config
 * Tokens extraits des slides de soutenance (DA univers spatial).
 */
const config: Config = {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        // ---- Palette spatiale Galaxis (cf. slide 01)
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
      },
      fontFamily: {
        display: ["'Space Grotesk'", "sans-serif"],
        sans: ["Inter", "sans-serif"],
        mono: ["'JetBrains Mono'", "monospace"],
      },
      backgroundImage: {
        "galaxis-gradient":
          "linear-gradient(135deg, #07A9DD 0%, #60D5FF 25%, #A76EC8 60%, #7B3E97 100%)",
        "galaxis-radial":
          "radial-gradient(ellipse at 80% 20%, rgba(123,62,151,0.18) 0%, transparent 50%), radial-gradient(ellipse at 20% 80%, rgba(18,125,194,0.12) 0%, transparent 50%)",
      },
      boxShadow: {
        glow: "0 0 32px rgba(96,213,255,0.25)",
        orb: "0 8px 32px rgba(0,0,0,0.6)",
      },
      animation: {
        "orbit-slow": "spin 60s linear infinite",
        "orbit-reverse": "spin 90s linear reverse infinite",
        "pulse-glow": "pulse 4s cubic-bezier(0.4,0,0.6,1) infinite",
      },
      backdropBlur: {
        xs: "2px",
      },
    },
  },
  plugins: [],
};

export default config;
