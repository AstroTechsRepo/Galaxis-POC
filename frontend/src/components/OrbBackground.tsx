/*
 * Galaxis POC — OrbBackground
 *
 * Décor : 2 orbes floutés + champ d'étoiles statiques.
 * Reprend le motif des slides (orbites + étoiles + cross).
 */
export function OrbBackground() {
  return (
    <div className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
      {/* Orbes flous */}
      <div
        className="galaxis-orb"
        style={{
          top: "-180px",
          right: "-160px",
          width: "560px",
          height: "560px",
          background: "radial-gradient(circle, #7B3E97 0%, transparent 70%)",
        }}
      />
      <div
        className="galaxis-orb"
        style={{
          bottom: "-220px",
          left: "-200px",
          width: "640px",
          height: "640px",
          background: "radial-gradient(circle, #127DC2 0%, transparent 70%)",
          opacity: 0.4,
        }}
      />
      <div
        className="galaxis-orb"
        style={{
          top: "30%",
          left: "55%",
          width: "320px",
          height: "320px",
          background: "radial-gradient(circle, #A76EC8 0%, transparent 70%)",
          opacity: 0.25,
        }}
      />

      {/* Orbites */}
      <div
        className="absolute"
        style={{
          top: "-260px",
          right: "-260px",
          width: "740px",
          height: "740px",
          border: "1px solid rgba(167, 110, 200, 0.12)",
          borderRadius: "9999px",
          transform: "rotate(-15deg)",
        }}
      />
      <div
        className="absolute"
        style={{
          bottom: "-320px",
          left: "-260px",
          width: "680px",
          height: "680px",
          border: "1px solid rgba(7, 169, 221, 0.10)",
          borderRadius: "9999px",
          transform: "rotate(20deg)",
        }}
      />

      {/* Étoiles statiques */}
      {STARS.map((s, i) => (
        <span
          key={i}
          className="absolute rounded-full bg-white"
          style={{
            top: s.top,
            left: s.left,
            width: s.size,
            height: s.size,
            opacity: s.opacity,
          }}
        />
      ))}
    </div>
  );
}

const STARS = [
  { top: "12%", left: "18%", size: 1, opacity: 0.4 },
  { top: "8%", left: "35%", size: 2, opacity: 0.6 },
  { top: "22%", left: "55%", size: 1, opacity: 0.5 },
  { top: "15%", left: "72%", size: 3, opacity: 0.8 },
  { top: "28%", left: "88%", size: 2, opacity: 0.6 },
  { top: "40%", left: "8%", size: 1, opacity: 0.4 },
  { top: "45%", left: "28%", size: 2, opacity: 0.5 },
  { top: "52%", left: "92%", size: 1, opacity: 0.4 },
  { top: "65%", left: "12%", size: 3, opacity: 0.7 },
  { top: "70%", left: "38%", size: 2, opacity: 0.5 },
  { top: "78%", left: "62%", size: 1, opacity: 0.4 },
  { top: "82%", left: "85%", size: 2, opacity: 0.5 },
  { top: "88%", left: "22%", size: 3, opacity: 0.7 },
  { top: "92%", left: "48%", size: 1, opacity: 0.4 },
];
