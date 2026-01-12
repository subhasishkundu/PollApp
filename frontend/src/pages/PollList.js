import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { pollAPI } from '../services/api';
import './PollList.css';

function PollList({ onLogout }) {
  const [polls, setPolls] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    loadPolls();
  }, []);

  const loadPolls = async () => {
    try {
      const response = await pollAPI.list();
      setPolls(response.data);
    } catch (err) {
      console.error('Failed to load polls:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleVote = async (pollId, pollOptionId) => {
    try {
      await pollAPI.vote(pollId, pollOptionId);
      // Reload polls to get updated vote counts
      loadPolls();
    } catch (err) {
      console.error('Vote failed:', err);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    if (onLogout) {
      onLogout();
    }
    navigate('/login');
  };

  if (loading) return <div className="loading">Loading...</div>;

  return (
    <div className="poll-list-container">
      <header>
        <h1>Poll App</h1>
        <div>
          <button onClick={() => navigate('/create')}>Create Poll</button>
          <button onClick={handleLogout}>Logout</button>
        </div>
      </header>
      <div className="polls-grid">
        {polls.map((poll) => (
          <div key={poll.id} className="poll-card">
            <h3>{poll.title}</h3>
            <p>{poll.description}</p>
            <div className="poll-options">
              {poll.options && poll.options.length > 0 ? (
                poll.options.map((option) => (
                  <div key={option.id} className="poll-option">
                    <button
                      className="option-button"
                      onClick={() => handleVote(poll.id, option.id)}
                    >
                      {option.text}
                    </button>
                    <span className="vote-count">{option.vote_count || 0} votes</span>
                  </div>
                ))
              ) : (
                <div className="no-options-message">
                  No options available. This poll was created before the options feature was added.
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default PollList;
