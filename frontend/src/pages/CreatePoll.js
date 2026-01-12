import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { pollAPI } from '../services/api';
import './CreatePoll.css';

function CreatePoll() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [options, setOptions] = useState(['', '']);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const addOption = () => {
    setOptions([...options, '']);
  };

  const removeOption = (index) => {
    if (options.length > 2) {
      setOptions(options.filter((_, i) => i !== index));
    }
  };

  const updateOption = (index, value) => {
    const newOptions = [...options];
    newOptions[index] = value;
    setOptions(newOptions);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const validOptions = options.filter(opt => opt.trim() !== '');
    if (validOptions.length < 2) {
      setError('Please provide at least 2 options');
      return;
    }
    try {
      await pollAPI.create(title, description, validOptions);
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
          <div className="options-section">
            <label>Poll Options (at least 2 required):</label>
            {options.map((option, index) => (
              <div key={index} className="option-input-group">
                <input
                  type="text"
                  placeholder={`Option ${index + 1}`}
                  value={option}
                  onChange={(e) => updateOption(index, e.target.value)}
                  required
                />
                {options.length > 2 && (
                  <button
                    type="button"
                    className="remove-option"
                    onClick={() => removeOption(index)}
                  >
                    ×
                  </button>
                )}
              </div>
            ))}
            <button
              type="button"
              className="add-option"
              onClick={addOption}
            >
              + Add Option
            </button>
          </div>
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
