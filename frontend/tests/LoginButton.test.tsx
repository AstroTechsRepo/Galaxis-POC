import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";

// On mocke oidc-client-ts pour ne pas exécuter la redirection navigateur
const signinRedirectSpy = vi.fn().mockResolvedValue(undefined);
vi.mock("@/lib/oidc", () => ({
  login: () => signinRedirectSpy(),
  logout: vi.fn(),
  getUser: vi.fn().mockResolvedValue(null),
  userManager: {
    events: {
      addUserLoaded: vi.fn(),
      addUserUnloaded: vi.fn(),
      addSilentRenewError: vi.fn(),
      removeUserLoaded: vi.fn(),
      removeUserUnloaded: vi.fn(),
      removeSilentRenewError: vi.fn(),
    },
  },
}));

import { LoginButton } from "@/components/LoginButton";

describe("LoginButton", () => {
  it("renders with the default label", () => {
    render(<LoginButton />);
    expect(screen.getByTestId("login-button")).toHaveTextContent(/se connecter/i);
  });

  it("calls login() (which triggers the PKCE redirect) on click", async () => {
    render(<LoginButton />);
    fireEvent.click(screen.getByTestId("login-button"));
    // login() est appelé immédiatement (await dans le handler)
    await Promise.resolve();
    expect(signinRedirectSpy).toHaveBeenCalledTimes(1);
  });

  it("shows a loading state while redirect is pending", async () => {
    render(<LoginButton label="GO" />);
    const btn = screen.getByTestId("login-button");
    fireEvent.click(btn);
    expect(btn).toBeDisabled();
  });
});
