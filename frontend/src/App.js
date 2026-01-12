import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Register from './pages/Register';
import PollList from './pages/PollList';
import CreatePoll from './pages/CreatePoll';
import './App.css';

function App() {
  const isAuthenticated = !!localStorage.getItem('token');

  return (
    <Router>
      <Routes>
        <Route path="/login" element={!isAuthenticated ? <Login /> : <Navigate to="/" />} />
        <Route path="/register" element={!isAuthenticated ? <Register /> : <Navigate to="/" />} />
        <Route path="/" element={isAuthenticated ? <PollList /> : <Navigate to="/login" />} />
        <Route path="/create" element={isAuthenticated ? <CreatePoll /> : <Navigate to="/login" />} />
      </Routes>
    </Router>
  );
}

export default App;
