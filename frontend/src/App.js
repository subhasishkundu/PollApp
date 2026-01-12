import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Register from './pages/Register';
import PollList from './pages/PollList';
import CreatePoll from './pages/CreatePoll';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('token'));

  useEffect(() => {
    // Check authentication status on mount
    setIsAuthenticated(!!localStorage.getItem('token'));

    // Listen for storage changes (for cross-tab updates)
    const handleStorageChange = () => {
      setIsAuthenticated(!!localStorage.getItem('token'));
    };

    window.addEventListener('storage', handleStorageChange);
    
    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  }, []);

  return (
    <Router>
      <Routes>
        <Route path="/login" element={!isAuthenticated ? <Login onLogin={() => setIsAuthenticated(true)} /> : <Navigate to="/" />} />
        <Route path="/register" element={!isAuthenticated ? <Register /> : <Navigate to="/" />} />
        <Route path="/" element={isAuthenticated ? <PollList onLogout={() => setIsAuthenticated(false)} /> : <Navigate to="/login" />} />
        <Route path="/create" element={isAuthenticated ? <CreatePoll /> : <Navigate to="/login" />} />
      </Routes>
    </Router>
  );
}

export default App;
