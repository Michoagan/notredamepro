import React, { Suspense, lazy } from 'react';
import { Routes, Route, Outlet } from 'react-router-dom';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import ProtectedRoute from './components/ProtectedRoute';
import StudentLayout from './layouts/StudentLayout';

// Lazy loading pages for better performance
const Home = lazy(() => import('./pages/Public/Home'));
const About = lazy(() => import('./pages/Public/About'));
const Classes = lazy(() => import('./pages/Public/Classes'));
const Rules = lazy(() => import('./pages/Public/Rules'));
const News = lazy(() => import('./pages/Public/News'));
const Contact = lazy(() => import('./pages/Public/Contact'));

const Login = lazy(() => import('./pages/Student/Login'));
const Register = lazy(() => import('./pages/Student/Register'));

// Student Pages
const StudentDashboard = lazy(() => import('./pages/Student/Dashboard'));
const Epreuves = lazy(() => import('./pages/Student/Epreuves'));
const Notes = lazy(() => import('./pages/Student/Notes'));
const Exercices = lazy(() => import('./pages/Student/Exercices'));
const Contacts = lazy(() => import('./pages/Student/Contacts'));
const Archives = lazy(() => import('./pages/Student/Archives'));

// Loading fallback component
const PageLoader = () => (
  <div style={{ minHeight: '60vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ width: '40px', height: '40px', border: '4px solid hsl(var(--primary-light))', borderTopColor: 'hsl(var(--primary))', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
    <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
  </div>
);

// Public Layout
const PublicLayout = () => (
  <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
    <Navbar />
    <main style={{ flex: '1 0 auto' }}>
      <Outlet />
    </main>
    <Footer />
  </div>
);

function App() {
  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        {/* Public Routes with Navbar & Footer */}
        <Route element={<PublicLayout />}>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/classes" element={<Classes />} />
          <Route path="/rules" element={<Rules />} />
          <Route path="/news" element={<News />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="/student/login" element={<Login />} />
          <Route path="/student/register" element={<Register />} />
        </Route>

        {/* Protected Student Routes with Sidebar Layout */}
        <Route
          path="/student"
          element={
            <ProtectedRoute>
              <StudentLayout />
            </ProtectedRoute>
          }
        >
          <Route path="dashboard" element={<StudentDashboard />} />
          <Route path="epreuves" element={<Epreuves />} />
          <Route path="notes" element={<Notes />} />
          <Route path="archives" element={<Archives />} />
          <Route path="exercices" element={<Exercices />} />
          <Route path="contacts" element={<Contacts />} />
        </Route>
      </Routes>
    </Suspense>
  );
}

export default App;
