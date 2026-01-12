import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const authAPI = {
  register: (username, email, password) =>
    api.post('/auth/register', { username, email, password }),
  login: (email, password) =>
    api.post('/auth/login', { email, password }),
};

export const pollAPI = {
  list: () => api.get('/polls'),
  get: (id) => api.get(`/polls/${id}`),
  create: (title, description, options) =>
    api.post('/polls', { title, description, options }),
  update: (id, title, description) =>
    api.put(`/polls/${id}`, { title, description }),
  delete: (id) => api.delete(`/polls/${id}`),
  vote: (pollId, pollOptionId) =>
    api.post(`/polls/${pollId}/vote`, { poll_option_id: pollOptionId }),
};
