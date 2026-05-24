import "@testing-library/jest-dom";
import { afterEach, vi } from "vitest";
import { cleanup } from "@testing-library/react";

afterEach(() => {
  cleanup();
});

// Mock global fetch — chaque test peut le surcharger
globalThis.fetch = vi.fn().mockResolvedValue(
  new Response(JSON.stringify({}), { status: 200, headers: { "Content-Type": "application/json" } }),
);
