# Poll App

An online polling application with Go backend and React frontend.

## Features

- User authentication (JWT-based)
- Create, read, update, and delete polls
- Upvote/downvote functionality
- Modern, responsive UI

## Tech Stack

### Backend
- Go 1.21+
- httprouter for routing
- MySQL database
- ent ORM
- JWT authentication

### Frontend
- React 18
- React Router
- Axios for API calls

## Setup Instructions

### Backend Setup

1. Install dependencies:
```bash
cd backend
go mod download
```

2. Generate ent code:
```bash
go generate ./ent
```

3. Create MySQL database:
```sql
CREATE DATABASE pollapp;
```

4. Update database connection in `cmd/server/main.go`:
```go
db, err := sql.Open("mysql", "root:password@tcp(localhost:3306)/pollapp?parseTime=True")
```

5. Run migrations (ent will auto-create tables on first run):
```bash
go run cmd/server/main.go
```

### Frontend Setup

1. Install dependencies:
```bash
cd frontend
npm install
```

2. Start development server:
```bash
npm start
```

The frontend will run on http://localhost:3000 and the backend on http://localhost:8080.

## API Endpoints

### Public
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Protected (requires JWT token)
- `GET /api/polls` - List all polls
- `GET /api/polls/:id` - Get poll by ID
- `POST /api/polls` - Create new poll
- `PUT /api/polls/:id` - Update poll
- `DELETE /api/polls/:id` - Delete poll
- `POST /api/polls/:id/upvote` - Upvote poll
- `POST /api/polls/:id/downvote` - Downvote poll
