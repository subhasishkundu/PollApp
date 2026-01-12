import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { pollAPI } from '../services/api';
import './PollList.css';

function PollList() {
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

  const handleVote = async (pollId, isUpvote) => {
    try {
      if (isUpvote) {
        await pollAPI.upvote(pollId);
      } else {
        await pollAPI.downvote(pollId);
      }
      loadPolls();
    } catch (err) {
      console.error('Vote failed:', err);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
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
            <div className="vote-buttons">
              <button onClick={() => handleVote(poll.id, true)}>👍 Upvote</button>
              <button onClick={() => handleVote(poll.id, false)}>👎 Downvote</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default PollList;
