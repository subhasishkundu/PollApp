# Poll App

A full-stack online polling application built with Go backend and React frontend. Users can create polls with multiple options, vote on them, and see real-time vote counts.

## Features

- **User Authentication**: JWT-based authentication with secure password hashing
- **Poll Management**: Create, read, update, and delete polls
- **Multiple Options**: Each poll can have multiple voting options (minimum 2)
- **Voting System**: Users can vote on any option and change their vote
- **Real-time Vote Counts**: See vote counts update in real-time
- **Modern UI**: Responsive, modern interface built with React
- **CORS Support**: Configured for frontend-backend communication

## Tech Stack

### Backend
- **Go 1.23+**: Programming language
- **httprouter**: Fast HTTP router
- **MySQL**: Relational database
- **ent ORM**: Type-safe ORM for Go
- **JWT (golang-jwt/jwt/v5)**: JSON Web Token authentication
- **bcrypt**: Password hashing

### Frontend
- **React 18**: UI library
- **React Router**: Client-side routing
- **Axios**: HTTP client for API calls
- **CSS3**: Modern styling

## Project Structure

```
PollApp/
├── backend/
│   ├── cmd/
│   │   └── server/
│   │       └── main.go          # Application entry point
│   ├── internal/
│   │   ├── auth/                # Authentication handlers
│   │   ├── handler/              # HTTP handlers
│   │   ├── middleware/           # JWT authentication middleware
│   │   └── service/              # Business logic layer
│   ├── ent/                      # Generated ent code
│   │   ├── schema/               # Database schemas
│   │   └── generate.go           # Code generation script
│   ├── scripts/
│   │   └── reset-db.sql          # Database reset script
│   └── go.mod                    # Go dependencies
├── frontend/
│   ├── src/
│   │   ├── components/           # React components
│   │   ├── pages/                # Page components
│   │   │   ├── Login.js          # Login page
│   │   │   ├── Register.js      # Registration page
│   │   │   ├── PollList.js      # Poll listing page
│   │   │   └── CreatePoll.js    # Create poll page
│   │   ├── services/
│   │   │   └── api.js            # API client
│   │   └── App.js                # Main app component
│   └── package.json              # Node dependencies
├── scripts/
│   └── setup-mysql.sh            # Complete MySQL installation and setup script
├── reset-database.sh             # Database reset script
├── run-backend.sh                # Backend startup script
├── run-frontend.sh                # Frontend startup script
└── README.md                     # This file
```

## Prerequisites

- **Go 1.23+**: [Install Go](https://golang.org/doc/install)
- **Node.js 16+** and **npm**: [Install Node.js](https://nodejs.org/)
- **MySQL 8.0+**: [Install MySQL](https://dev.mysql.com/downloads/mysql/)

## Setup Instructions

### 1. Database Setup

#### Option A: Automated Setup (RHEL/CentOS/Fedora)

For a complete automated setup including MySQL installation:

```bash
sudo ./scripts/setup-mysql.sh
```

This script will:
- Install MySQL Server using yum
- Start and enable MySQL service
- Configure root user with password "password"
- Create the `pollapp` database
- Create all required tables with proper constraints

**Note:** This script requires root/sudo privileges and is designed for RHEL/CentOS/Fedora systems.

#### Option B: Manual Setup

If MySQL is already installed, create the database manually:

```bash
mysql -u root -p
```

```sql
CREATE DATABASE pollapp;
EXIT;
```

Then run the schema creation script:

```bash
cd backend
./scripts/create-schema.sh
```

### 2. Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install Go dependencies:**
   ```bash
   go mod download
   ```

3. **Generate ent code:**
   ```bash
   go generate ./ent
   ```

4. **Create database schema:**
   
   Run the schema creation script:
   ```bash
   ./scripts/create-schema.sh
   ```
   
   Or use the migration wrapper:
   ```bash
   ./scripts/migrate.sh
   ```
   
   The script will:
   - Create the database if it doesn't exist
   - Drop existing tables (if any) for clean setup
   - Create all required tables with proper constraints
   - Verify the tables were created successfully

5. **Configure database connection:**
   
   Update the database credentials in `cmd/server/main.go` (lines 22-39) or set environment variables:
   ```bash
   export DB_USER=root
   export DB_PASSWORD=your_password
   export DB_HOST=localhost:3306
   export DB_NAME=pollapp
   ```

6. **Start the server:**
   ```bash
   go run cmd/server/main.go
   ```
   
   Or use the helper script:
   ```bash
   ./run-backend.sh
   ```

   The server will start on `http://localhost:8080` and verify that all required tables exist.

### 3. Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start development server:**
   ```bash
   npm start
   ```
   
   Or use the helper script:
   ```bash
   ./run-frontend.sh
   ```

   The frontend will start on `http://localhost:3000` and open in your browser.

## Usage

### Creating a Poll

1. Log in or register a new account
2. Click "Create Poll"
3. Enter poll title and description
4. Add at least 2 options (use "+ Add Option" for more)
5. Click "Create Poll"

### Voting

1. Browse polls on the home page
2. Click any option button to vote
3. Vote counts update automatically
4. You can change your vote by clicking a different option

### Managing Polls

- **View all polls**: Listed on the home page
- **Update poll**: Only the creator can update (feature to be implemented)
- **Delete poll**: Only the creator can delete (feature to be implemented)

## API Documentation

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Poll Endpoints

#### List All Polls
```http
GET /api/polls
```

**Response:**
```json
[
  {
    "id": 1,
    "title": "Best Programming Language",
    "description": "Which language do you prefer?",
    "created_by": 1,
    "created_at": "2026-01-12T10:00:00Z",
    "options": [
      {
        "id": 1,
        "text": "Go",
        "order": 0,
        "vote_count": 5
      },
      {
        "id": 2,
        "text": "Python",
        "order": 1,
        "vote_count": 3
      }
    ]
  }
]
```

#### Create Poll
```http
POST /api/polls
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Best Programming Language",
  "description": "Which language do you prefer?",
  "options": ["Go", "Python", "JavaScript"]
}
```

#### Vote on Poll
```http
POST /api/polls/:id/vote
Authorization: Bearer <token>
Content-Type: application/json

{
  "poll_option_id": 1
}
```

**Response:**
```json
{
  "vote_counts": {
    "1": 6,
    "2": 3
  }
}
```

#### Get Poll by ID
```http
GET /api/polls/:id
```

#### Update Poll
```http
PUT /api/polls/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Title",
  "description": "Updated description"
}
```

#### Delete Poll
```http
DELETE /api/polls/:id
Authorization: Bearer <token>
```

## Database Schema

### Users Table
- `id` (int, primary key)
- `username` (string, unique)
- `email` (string, unique)
- `password_hash` (string)
- `created_at` (timestamp)

### Polls Table
- `id` (int, primary key)
- `title` (string)
- `description` (string)
- `created_by` (int, foreign key to users)
- `created_at` (timestamp)

### Poll Options Table
- `id` (int, primary key)
- `poll_id` (int, foreign key to polls)
- `option_text` (string)
- `order` (int)

### Votes Table
- `id` (int, primary key)
- `poll_id` (int, foreign key to polls)
- `poll_option_id` (int, foreign key to poll_options)
- `user_id` (int, foreign key to users)
- `created_at` (timestamp)

## Database Management

### Create Schema

To create the database schema (run this first):

```bash
cd backend
./scripts/create-schema.sh
```

Or use the migration wrapper:
```bash
./scripts/migrate.sh
```

**Environment Variables:**
You can override database credentials:
```bash
DB_USER=root DB_PASSWORD=yourpass DB_NAME=pollapp ./scripts/create-schema.sh
```

### Reset Database

To clear all data and start fresh (keeps tables, removes data):

```bash
./reset-database.sh
```

Or manually:
```bash
mysql -u root -padmin pollapp < backend/scripts/reset-db.sql
```

**Note:** 
- After resetting, you'll need to log in again as all users are deleted.
- If you need to recreate tables, run the migration script again.

## Environment Variables

### Backend

- `DB_USER`: MySQL username (default: `root`)
- `DB_PASSWORD`: MySQL password (default: `admin`)
- `DB_HOST`: MySQL host and port (default: `localhost:3306`)
- `DB_NAME`: Database name (default: `pollapp`)
- `PORT`: Server port (default: `8080`)

## Troubleshooting

### Database Connection Issues

- Ensure MySQL is running: `mysql.server start` (macOS) or `sudo systemctl start mysql` (Linux)
- Verify database exists: `mysql -u root -p -e "SHOW DATABASES;"`
- Check credentials in `cmd/server/main.go`

### Port Already in Use

- Backend (8080): Change `PORT` environment variable or kill the process: `lsof -ti:8080 | xargs kill -9`
- Frontend (3000): React will automatically use the next available port

### Options Not Showing

- Ensure you created the poll with options (at least 2)
- Check browser console for errors
- Verify the poll was created after the options feature was added
- Delete old polls and create new ones

### Authentication Issues

- Clear browser localStorage: `localStorage.removeItem('token')`
- Log in again to get a fresh token
- Ensure the user exists in the database

## Development

### Backend Development

```bash
cd backend
go run cmd/server/main.go
```

### Frontend Development

```bash
cd frontend
npm start
```

### Viewing Logs

Backend logs are written to `/tmp/pollapp-server.log` when run in background, or displayed in terminal when run normally.

To view logs in real-time:
```bash
tail -f /tmp/pollapp-server.log
```

## Security Notes

- **JWT Secret**: Change the JWT secret in `internal/service/auth.go` for production
- **Password Hashing**: Uses bcrypt with default cost
- **CORS**: Currently allows all origins (`*`) - restrict in production
- **Database Credentials**: Use environment variables in production, never hardcode

## License

This project is open source and available for educational purposes.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Support

For issues or questions, please check the troubleshooting section or open an issue in the repository.
