import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";

const events = {
  addUserLoaded: vi.fn(),
  addUserUnloaded: vi.fn(),
  addSilentRenewError: vi.fn(),
  removeUserLoaded: vi.fn(),
  removeUserUnloaded: vi.fn(),
  removeSilentRenewError: vi.fn(),
};
const fakeUser = { access_token: "tk", profile: { preferred_username: "test" }, expired: false };

vi.mock("@/lib/oidc", () => ({
  getUser: vi.fn().mockResolvedValue(fakeUser),
  login: vi.fn(),
  logout: vi.fn(),
  userManager: { events },
}));

beforeEach(() => {
  vi.clearAllMocks();
});

import { useAuth } from "@/hooks/useAuth";

describe("useAuth", () => {
  it("passe de loading à authenticated quand un user est trouvé", async () => {
    const { result } = renderHook(() => useAuth());
    expect(result.current.status).toBe("loading");
    await waitFor(() => expect(result.current.status).toBe("authenticated"));
    expect(result.current.token).toBe("tk");
  });

  it("souscrit/se désouscrit des events oidc-client-ts", async () => {
    const { unmount } = renderHook(() => useAuth());
    await waitFor(() => expect(events.addUserLoaded).toHaveBeenCalled());
    unmount();
    expect(events.removeUserLoaded).toHaveBeenCalled();
    expect(events.removeUserUnloaded).toHaveBeenCalled();
    expect(events.removeSilentRenewError).toHaveBeenCalled();
  });
});
