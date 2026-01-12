package main

import (
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
	// Database connection
	db, err := sql.Open("mysql", "root:password@tcp(localhost:3306)/pollapp?parseTime=True")
	if err != nil {
		log.Fatal("Failed to open database:", err)
	}
	defer db.Close()

	// Create ent client
	drv := entsql.OpenDB(dialect.MySQL, db)
	client := handler.NewEntClient(drv)

	// Initialize services
	authService := service.NewAuthService(client)
	pollService := service.NewPollService(client)

	// Initialize handlers
	authHandler := handler.NewAuthHandler(authService)
	pollHandler := handler.NewPollHandler(pollService)

	// Setup router
	router := httprouter.New()

	// Public routes
	router.POST("/api/auth/register", authHandler.Register)
	router.POST("/api/auth/login", authHandler.Login)

	// Protected routes
	router.POST("/api/polls", middleware.AuthMiddleware(authService, pollHandler.CreatePoll))
	router.GET("/api/polls", pollHandler.ListPolls)
	router.GET("/api/polls/:id", pollHandler.GetPoll)
	router.PUT("/api/polls/:id", middleware.AuthMiddleware(authService, pollHandler.UpdatePoll))
	router.DELETE("/api/polls/:id", middleware.AuthMiddleware(authService, pollHandler.DeletePoll))
	router.POST("/api/polls/:id/upvote", middleware.AuthMiddleware(authService, pollHandler.Upvote))
	router.POST("/api/polls/:id/downvote", middleware.AuthMiddleware(authService, pollHandler.Downvote))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, router))
}
