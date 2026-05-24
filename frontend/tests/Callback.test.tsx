import { describe, it, expect, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";

const completeSpy = vi.fn();
const navigateMock = vi.fn();

vi.mock("@/lib/oidc", () => ({
  completeLogin: () => completeSpy(),
}));

vi.mock("react-router-dom", async () => {
  const actual = await vi.importActual<typeof import("react-router-dom")>("react-router-dom");
  return {
    ...actual,
    useNavigate: () => navigateMock,
  };
});

import { Callback } from "@/pages/Callback";

describe("Callback page", () => {
  it("échange le code et redirige vers /dashboard en cas de succès", async () => {
    completeSpy.mockResolvedValueOnce(undefined);
    render(
      <MemoryRouter>
        <Callback />
      </MemoryRouter>,
    );
    expect(screen.getByTestId("callback")).toBeInTheDocument();
    await waitFor(() =>
      expect(navigateMock).toHaveBeenCalledWith("/dashboard", { replace: true }),
    );
  });

  it("affiche l'erreur si l'échange échoue", async () => {
    completeSpy.mockRejectedValueOnce(new Error("invalid grant"));
    render(
      <MemoryRouter>
        <Callback />
      </MemoryRouter>,
    );
    await waitFor(() => {
      expect(screen.getByText(/Échec de la connexion/i)).toBeInTheDocument();
    });
    expect(screen.getByText(/invalid grant/i)).toBeInTheDocument();
  });
});
