package middleware

import (
	"context"
	"net/http"

	"pollapp/backend/internal/service"

	"github.com/golang-jwt/jwt/v5"
	"github.com/julienschmidt/httprouter"
)

func AuthMiddleware(authService *service.AuthService, handler httprouter.Handle) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		tokenString := r.Header.Get("Authorization")
		if tokenString == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if len(tokenString) > 7 && tokenString[:7] == "Bearer " {
			tokenString = tokenString[7:]
		}

		token, err := authService.ValidateToken(tokenString)
		if err != nil || !token.Valid {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userID, ok := claims["user_id"].(float64)
		if !ok {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), "userID", int(userID))
		handler(w, r.WithContext(ctx), ps)
	}
}
