import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';

const ProtectedRoute = ({ children }) => {
    const location = useLocation();
    // We'll mock authentication state for now. In a real app, this reads from an Auth Context or localStorage.
    const token = localStorage.getItem('eleve_token');

    if (!token) {
        // If not authenticated, redirect to login page and pass the intended destination
        return <Navigate to="/student/login" state={{ from: location }} replace />;
    }

    // If authenticated, render the children (the protected dashboard)
    return children;
};

export default ProtectedRoute;
