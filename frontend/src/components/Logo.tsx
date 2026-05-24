/*
 * Galaxis POC — Logo (wordmark)
 * Reprend l'esprit du titre des slides.
 */
export function Logo({ size = 28 }: { size?: number }) {
  return (
    <div className="flex items-center gap-2 select-none">
      <svg
        width={size}
        height={size}
        viewBox="0 0 32 32"
        xmlns="http://www.w3.org/2000/svg"
        aria-hidden="true"
      >
        <defs>
          <linearGradient id="logoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#07A9DD" />
            <stop offset="50%" stopColor="#60D5FF" />
            <stop offset="100%" stopColor="#7B3E97" />
          </linearGradient>
        </defs>
        <circle cx="16" cy="16" r="13" fill="#0D0B1A" />
        <circle cx="16" cy="16" r="8" fill="none" stroke="url(#logoGrad)" strokeWidth="2" />
        <circle cx="16" cy="16" r="2.5" fill="url(#logoGrad)" />
        <ellipse
          cx="16"
          cy="16"
          rx="13"
          ry="4.5"
          fill="none"
          stroke="#7B3E97"
          strokeWidth="1"
          opacity="0.6"
        />
      </svg>
      <span
        className="font-display text-xl font-semibold tracking-tight galaxis-text-gradient"
        style={{ fontSize: `${size * 0.65}px` }}
      >
        Galaxis
      </span>
    </div>
  );
}
