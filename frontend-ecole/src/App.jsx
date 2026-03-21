import React, { Suspense, lazy } from 'react';
import { Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import ProtectedRoute from './components/ProtectedRoute';

// Lazy loading pages for better performance
const Home = lazy(() => import('./pages/Public/Home'));
const About = lazy(() => import('./pages/Public/About'));
const Classes = lazy(() => import('./pages/Public/Classes'));
const Rules = lazy(() => import('./pages/Public/Rules'));
const News = lazy(() => import('./pages/Public/News'));
const Contact = lazy(() => import('./pages/Public/Contact'));

const Login = lazy(() => import('./pages/Student/Login'));
const Register = lazy(() => import('./pages/Student/Register'));
const StudentDashboard = lazy(() => import('./pages/Student/Dashboard'));

// Loading fallback component
const PageLoader = () => (
  <div style={{ minHeight: '60vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ width: '40px', height: '40px', border: '4px solid hsl(var(--primary-light))', borderTopColor: 'hsl(var(--primary))', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
    <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
  </div>
);

function App() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <Navbar />

      <main style={{ flex: '1 0 auto' }}>
        <Suspense fallback={<PageLoader />}>
          <Routes>
            {/* Public Routes */}
            <Route path="/" element={<Home />} />
            <Route path="/about" element={<About />} />
            <Route path="/classes" element={<Classes />} />
            <Route path="/rules" element={<Rules />} />
            <Route path="/news" element={<News />} />
            <Route path="/contact" element={<Contact />} />

            {/* Auth Routes */}
            <Route path="/student/login" element={<Login />} />
            <Route path="/student/register" element={<Register />} />

            {/* Protected Student Routes */}
            <Route
              path="/student/dashboard"
              element={
                <ProtectedRoute>
                  <StudentDashboard />
                </ProtectedRoute>
              }
            />
          </Routes>
        </Suspense>
      </main>

      <Footer />
    </div>
  );
}

export default App;
