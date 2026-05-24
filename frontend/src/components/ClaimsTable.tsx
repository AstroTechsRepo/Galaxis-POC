import type { GalaxisClaims } from "@/types/auth";

/*
 * Galaxis POC — ClaimsTable
 *
 * Affiche un sous-ensemble de claims du JWT pour le debug / la démo
 * jury. Met en valeur sub, email, exp, aud, roles.
 */
export function ClaimsTable({ claims }: { claims: GalaxisClaims }) {
  const rows: Array<[string, React.ReactNode]> = [
    ["sub", <code key="sub" className="galaxis-mono">{claims.sub}</code>],
    ["preferred_username", claims.preferred_username ?? "—"],
    ["email", claims.email ?? "—"],
    ["given_name", claims.given_name ?? "—"],
    ["family_name", claims.family_name ?? "—"],
    ["iss", <code key="iss" className="galaxis-mono break-all">{claims.iss}</code>],
    ["aud", <code key="aud" className="galaxis-mono">{Array.isArray(claims.aud) ? claims.aud.join(", ") : (claims.aud ?? "")}</code>],
    ["iat", claims.iat ? new Date(claims.iat * 1000).toLocaleString("fr-FR") : "—"],
    ["exp", claims.exp ? new Date(claims.exp * 1000).toLocaleString("fr-FR") : "—"],
    [
      "realm_roles",
      <span key="roles" className="galaxis-mono text-xs">
        {claims.realm_access?.roles?.join(", ") ?? "—"}
      </span>,
    ],
  ];

  return (
    <div className="galaxis-card overflow-hidden rounded-2xl">
      <div className="border-b border-white/5 px-5 py-3">
        <h3 className="font-display text-sm font-semibold uppercase tracking-wider text-white/80">
          Claims JWT (décodés serveur)
        </h3>
      </div>
      <table className="w-full text-sm" data-testid="claims-table">
        <tbody>
          {rows.map(([label, value]) => (
            <tr key={label} className="border-b border-white/5 last:border-b-0">
              <th className="w-48 px-5 py-2.5 text-left font-medium text-white/60">{label}</th>
              <td className="px-5 py-2.5 text-white/90">{value}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
