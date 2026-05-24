import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";

// Auth mockée : utilisateur authentifié
vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => ({
    status: "authenticated",
    token: "fake-token",
    user: { profile: { preferred_username: "lucas-test", given_name: "Lucas" } },
    login: vi.fn(),
    logout: vi.fn(),
  }),
}));

// API mockée
vi.mock("@/lib/api", () => ({
  fetchMe: vi.fn().mockResolvedValue({
    user: {
      id: 1,
      username: "lucas-test",
      email: "lucas-test@galaxis.local",
      first_name: "Lucas",
      last_name: "Test",
    },
    claims: {
      sub: "abc-123",
      preferred_username: "lucas-test",
      email: "lucas-test@galaxis.local",
      given_name: "Lucas",
      family_name: "Test",
      iss: "http://localhost:8080/iam/realms/galaxis",
      aud: "galaxis-portal",
      iat: 1700000000,
      exp: 1700003600,
      realm_access: { roles: ["user"] },
    },
  }),
  fetchAudit: vi.fn().mockResolvedValue([]),
}));

beforeEach(() => {
  vi.clearAllMocks();
});

import { Dashboard } from "@/pages/Dashboard";

describe("Dashboard", () => {
  it("affiche le nom du user et les cartes de briques", async () => {
    render(
      <MemoryRouter>
        <Dashboard />
      </MemoryRouter>,
    );

    expect(await screen.findByText(/Bienvenue/i)).toBeInTheDocument();
    expect(screen.getByText(/Lucas/)).toBeInTheDocument();
    expect(screen.getByText("Vaultwarden")).toBeInTheDocument();
    expect(screen.getByText("Nextcloud")).toBeInTheDocument();
  });

  it("affiche les claims du JWT une fois /api/me chargé", async () => {
    render(
      <MemoryRouter>
        <Dashboard />
      </MemoryRouter>,
    );
    await waitFor(() => {
      expect(screen.getByTestId("claims-table")).toBeInTheDocument();
    });
    expect(screen.getByText(/abc-123/)).toBeInTheDocument();
  });

  it("lie le bouton Vaultwarden vers /vault/", async () => {
    render(
      <MemoryRouter>
        <Dashboard />
      </MemoryRouter>,
    );
    const card = await screen.findByTestId("brick-vaultwarden");
    expect(card).toHaveAttribute("href", "/vault/");
  });
});
