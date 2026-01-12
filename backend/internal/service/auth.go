package service

import (
	"context"
	"errors"
	"time"

	"pollapp/backend/ent"
	"pollapp/backend/ent/user"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	client *ent.Client
	secret []byte
}

func NewAuthService(client *ent.Client) *AuthService {
	return &AuthService{
		client: client,
		secret: []byte("your-secret-key-change-in-production"),
	}
}

func (s *AuthService) Register(ctx context.Context, username, email, password string) (*ent.User, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	u, err := s.client.User.Create().
		SetUsername(username).
		SetEmail(email).
		SetPasswordHash(string(hashedPassword)).
		Save(ctx)
	if err != nil {
		return nil, err
	}

	return u, nil
}

func (s *AuthService) Login(ctx context.Context, email, password string) (string, error) {
	u, err := s.client.User.Query().
		Where(user.EmailEQ(email)).
		Only(ctx)
	if err != nil {
		return "", errors.New("invalid credentials")
	}

	err = bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(password))
	if err != nil {
		return "", errors.New("invalid credentials")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id":  u.ID,
		"username": u.Username,
		"exp":      time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString(s.secret)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func (s *AuthService) ValidateToken(tokenString string) (*jwt.Token, error) {
	return jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return s.secret, nil
	})
}
