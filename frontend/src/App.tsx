import { Route, Routes } from "react-router-dom";
import { Footer } from "@/components/Footer";
import { Header } from "@/components/Header";
import { OrbBackground } from "@/components/OrbBackground";
import { Landing } from "@/pages/Landing";
import { Callback } from "@/pages/Callback";
import { Dashboard } from "@/pages/Dashboard";
import { Profile } from "@/pages/Profile";
import { NotFound } from "@/pages/NotFound";

/*
 * Galaxis POC — App
 * Routing principal + chrome (header/footer/background).
 */
function App() {
  return (
    <div className="relative flex min-h-screen flex-col">
      <OrbBackground />
      <Header />
      <Routes>
        <Route path="/" element={<Landing />} />
        <Route path="/auth/callback" element={<Callback />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
      <Footer />
    </div>
  );
}

export default App;
