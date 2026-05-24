import { useCallback, useEffect, useState } from "react";
import type { User } from "oidc-client-ts";
import { getUser, login, logout, userManager } from "@/lib/oidc";

/*
 * Galaxis POC — Hook useAuth
 *
 * Expose :
 *  - user : objet OIDC (avec access_token, profile)
 *  - status : "loading" | "anonymous" | "authenticated"
 *  - login() / logout()
 *
 * Souscrit aux events oidc-client-ts (signinComplete, silentRenewError, etc.)
 */

export type AuthStatus = "loading" | "anonymous" | "authenticated";

export interface UseAuthReturn {
  user: User | null;
  status: AuthStatus;
  login: () => Promise<void>;
  logout: () => Promise<void>;
  token: string | null;
}

export function useAuth(): UseAuthReturn {
  const [user, setUser] = useState<User | null>(null);
  const [status, setStatus] = useState<AuthStatus>("loading");

  useEffect(() => {
    let cancelled = false;

    void (async () => {
      try {
        const current = await getUser();
        if (cancelled) return;
        if (current && !current.expired) {
          setUser(current);
          setStatus("authenticated");
        } else {
          setUser(null);
          setStatus("anonymous");
        }
      } catch {
        if (!cancelled) {
          setUser(null);
          setStatus("anonymous");
        }
      }
    })();

    const onUserLoaded = (u: User) => {
      setUser(u);
      setStatus("authenticated");
    };
    const onUserUnloaded = () => {
      setUser(null);
      setStatus("anonymous");
    };
    const onSilentRenewError = () => {
      setUser(null);
      setStatus("anonymous");
    };

    userManager.events.addUserLoaded(onUserLoaded);
    userManager.events.addUserUnloaded(onUserUnloaded);
    userManager.events.addSilentRenewError(onSilentRenewError);

    return () => {
      cancelled = true;
      userManager.events.removeUserLoaded(onUserLoaded);
      userManager.events.removeUserUnloaded(onUserUnloaded);
      userManager.events.removeSilentRenewError(onSilentRenewError);
    };
  }, []);

  const doLogin = useCallback(() => login(), []);
  const doLogout = useCallback(() => logout(), []);

  return {
    user,
    status,
    login: doLogin,
    logout: doLogout,
    token: user?.access_token ?? null,
  };
}
