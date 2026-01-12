package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"os"

	"pollapp/backend/internal/handler"
	"pollapp/backend/internal/middleware"
	"pollapp/backend/internal/service"

	"entgo.io/ent/dialect"
	entsql "entgo.io/ent/dialect/sql"
	_ "github.com/go-sql-driver/mysql"
	"github.com/julienschmidt/httprouter"
)

func main() {
	// Database connection - read from environment variables or use defaults
	dbUser := os.Getenv("DB_USER")
	if dbUser == "" {
		dbUser = "root"
	}
	
	dbPassword := os.Getenv("DB_PASSWORD")
	if dbPassword == "" {
		dbPassword = "admin" // Change this to your MySQL password
	}
	
	dbHost := os.Getenv("DB_HOST")
	if dbHost == "" {
		dbHost = "localhost:3306"
	}
	
	dbName := os.Getenv("DB_NAME")
	if dbName == "" {
		dbName = "pollapp"
	}
	
	dsn := dbUser + ":" + dbPassword + "@tcp(" + dbHost + ")/" + dbName + "?parseTime=True"
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatal("Failed to open database:", err)
	}
	defer db.Close()

	// Test database connection
	if err := db.Ping(); err != nil {
		log.Fatal("Failed to ping database:", err)
	}
	log.Println("Database connection successful")

	// Create ent client
	drv := entsql.OpenDB(dialect.MySQL, db)
	client := handler.NewEntClient(drv)

	// Run database migrations
	ctx := context.Background()
	if err := client.Schema.Create(ctx); err != nil {
		log.Fatal("Failed to create schema:", err)
	}
	log.Println("Database schema created successfully")

	// Initialize services
	authService := service.NewAuthService(client)
	pollService := service.NewPollService(client)

	// Initialize handlers
	authHandler := handler.NewAuthHandler(authService)
	pollHandler := handler.NewPollHandler(pollService)

	// Setup router
	router := httprouter.New()

	// CORS middleware
	router.GlobalOPTIONS = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Access-Control-Request-Method") != "" {
			header := w.Header()
			header.Set("Access-Control-Allow-Origin", "*")
			header.Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			header.Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		}
		w.WriteHeader(http.StatusNoContent)
	})

	// Add CORS headers to all responses
	corsHandler := func(h httprouter.Handle) httprouter.Handle {
		return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
			h(w, r, ps)
		}
	}

	// Public routes
	router.POST("/api/auth/register", corsHandler(authHandler.Register))
	router.POST("/api/auth/login", corsHandler(authHandler.Login))

	// Protected routes
	router.POST("/api/polls", corsHandler(middleware.AuthMiddleware(authService, pollHandler.CreatePoll)))
	router.GET("/api/polls", corsHandler(pollHandler.ListPolls))
	router.GET("/api/polls/:id", corsHandler(pollHandler.GetPoll))
	router.PUT("/api/polls/:id", corsHandler(middleware.AuthMiddleware(authService, pollHandler.UpdatePoll)))
	router.DELETE("/api/polls/:id", corsHandler(middleware.AuthMiddleware(authService, pollHandler.DeletePoll)))
	router.POST("/api/polls/:id/vote", corsHandler(middleware.AuthMiddleware(authService, pollHandler.Vote)))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, router))
}
