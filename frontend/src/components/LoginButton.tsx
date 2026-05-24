import { useState } from "react";
import { login } from "@/lib/oidc";

/*
 * Galaxis POC — LoginButton
 *
 * Déclenche le flow OIDC Authorization Code + PKCE S256.
 * oidc-client-ts génère automatiquement le code_verifier, le hashe en
 * code_challenge S256 et redirige vers /iam/realms/galaxis/.../auth.
 */
export interface LoginButtonProps {
  label?: string;
  className?: string;
}

export function LoginButton({ label = "Se connecter", className = "" }: LoginButtonProps) {
  const [loading, setLoading] = useState(false);

  const onClick = async () => {
    setLoading(true);
    try {
      await login();
    } catch (e) {
      console.error("login failed", e);
      setLoading(false);
    }
  };

  return (
    <button
      type="button"
      onClick={() => void onClick()}
      disabled={loading}
      className={`galaxis-btn-gradient ${className}`.trim()}
      data-testid="login-button"
    >
      {loading ? "Redirection…" : label}
    </button>
  );
}
