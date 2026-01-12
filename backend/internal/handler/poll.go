package handler

import (
	"encoding/json"
	"net/http"
	"strconv"

	"pollapp/backend/internal/service"

	"github.com/julienschmidt/httprouter"
)

type PollHandler struct {
	service *service.PollService
}

func NewPollHandler(service *service.PollService) *PollHandler {
	return &PollHandler{service: service}
}

func (h *PollHandler) CreatePoll(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	userID := r.Context().Value("userID").(int)

	var req struct {
		Title       string `json:"title"`
		Description string `json:"description"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	poll, err := h.service.CreatePoll(r.Context(), userID, req.Title, req.Description)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(poll)
}

func (h *PollHandler) ListPolls(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	polls, err := h.service.ListPolls(r.Context())
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(polls)
}

func (h *PollHandler) GetPoll(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	id, _ := strconv.Atoi(ps.ByName("id"))
	poll, err := h.service.GetPoll(r.Context(), id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	json.NewEncoder(w).Encode(poll)
}

func (h *PollHandler) UpdatePoll(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	userID := r.Context().Value("userID").(int)
	id, _ := strconv.Atoi(ps.ByName("id"))

	var req struct {
		Title       string `json:"title"`
		Description string `json:"description"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	poll, err := h.service.UpdatePoll(r.Context(), id, userID, req.Title, req.Description)
	if err != nil {
		http.Error(w, err.Error(), http.StatusForbidden)
		return
	}

	json.NewEncoder(w).Encode(poll)
}

func (h *PollHandler) DeletePoll(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	userID := r.Context().Value("userID").(int)
	id, _ := strconv.Atoi(ps.ByName("id"))

	if err := h.service.DeletePoll(r.Context(), id, userID); err != nil {
		http.Error(w, err.Error(), http.StatusForbidden)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *PollHandler) Upvote(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	userID := r.Context().Value("userID").(int)
	id, _ := strconv.Atoi(ps.ByName("id"))

	if err := h.service.Upvote(r.Context(), id, userID); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *PollHandler) Downvote(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	userID := r.Context().Value("userID").(int)
	id, _ := strconv.Atoi(ps.ByName("id"))

	if err := h.service.Downvote(r.Context(), id, userID); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}
