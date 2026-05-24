/*
 * Galaxis POC — Types d'authentification.
 */

export interface GalaxisUser {
  id?: number;
  username: string;
  email?: string;
  first_name?: string;
  last_name?: string;
  last_login_at?: string;
}

export interface GalaxisClaims {
  sub: string;
  preferred_username?: string;
  email?: string;
  email_verified?: boolean;
  given_name?: string;
  family_name?: string;
  name?: string;
  iss?: string;
  aud?: string | string[];
  iat?: number;
  exp?: number;
  azp?: string;
  session_state?: string;
  realm_access?: { roles: string[] };
  resource_access?: Record<string, { roles: string[] }>;
}

export interface MeResponse {
  user: GalaxisUser | null;
  claims: GalaxisClaims;
}
