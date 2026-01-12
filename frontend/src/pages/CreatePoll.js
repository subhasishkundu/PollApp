import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { pollAPI } from '../services/api';
import './CreatePoll.css';

function CreatePoll() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await pollAPI.create(title, description);
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to create poll');
    }
  };

  return (
    <div className="create-poll-container">
      <div className="create-poll-card">
        <h2>Create New Poll</h2>
        {error && <div className="error">{error}</div>}
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="Poll Title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
          />
          <textarea
            placeholder="Poll Description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            required
            rows="5"
          />
          <div className="button-group">
            <button type="submit">Create Poll</button>
            <button type="button" onClick={() => navigate('/')}>Cancel</button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default CreatePoll;
