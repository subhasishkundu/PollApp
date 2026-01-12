package handler

import (
	"encoding/json"
	"log"
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
	w.Header().Set("Content-Type", "application/json")
	
	userID := r.Context().Value("userID").(int)

	var req struct {
		Title       string   `json:"title"`
		Description string   `json:"description"`
		Options     []string `json:"options"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Invalid request body"})
		return
	}

	// Validate options
	if len(req.Options) < 2 {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "poll must have at least 2 options"})
		return
	}

	poll, err := h.service.CreatePoll(r.Context(), userID, req.Title, req.Description, req.Options)
	if err != nil {
		log.Printf("CreatePoll error: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(poll)
}

func (h *PollHandler) ListPolls(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	w.Header().Set("Content-Type", "application/json")
	
	polls, err := h.service.ListPolls(r.Context())
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Add vote counts to each poll
	type OptionWithVotes struct {
		ID        int    `json:"id"`
		Text      string `json:"text"`
		Order     int    `json:"order"`
		VoteCount int    `json:"vote_count"`
	}

	type PollWithVotes struct {
		ID          int               `json:"id"`
		Title       string            `json:"title"`
		Description string            `json:"description"`
		CreatedBy   int               `json:"created_by"`
		CreatedAt   string            `json:"created_at"`
		Options     []OptionWithVotes `json:"options"`
	}

	result := make([]PollWithVotes, len(polls))
	for i, poll := range polls {
		voteCounts, err := h.service.GetVoteCounts(r.Context(), poll.ID)
		if err != nil {
			voteCounts = make(map[int]int)
		}

		options := make([]OptionWithVotes, 0)
		if poll.Edges.Options != nil {
			for _, option := range poll.Edges.Options {
				options = append(options, OptionWithVotes{
					ID:        option.ID,
					Text:      option.OptionText,
					Order:     option.Order,
					VoteCount: voteCounts[option.ID],
				})
			}
		}

		result[i] = PollWithVotes{
			ID:          poll.ID,
			Title:       poll.Title,
			Description: poll.Description,
			CreatedBy:   poll.CreatedBy,
			CreatedAt:   poll.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			Options:     options,
		}
	}

	json.NewEncoder(w).Encode(result)
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

func (h *PollHandler) Vote(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	w.Header().Set("Content-Type", "application/json")
	
	userID := r.Context().Value("userID").(int)
	pollID, _ := strconv.Atoi(ps.ByName("id"))

	var req struct {
		PollOptionID int `json:"poll_option_id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Invalid request body"})
		return
	}

	if err := h.service.Vote(r.Context(), pollID, req.PollOptionID, userID); err != nil {
		statusCode := http.StatusInternalServerError
		if err.Error() == "user not found" {
			statusCode = http.StatusUnauthorized
		}
		w.WriteHeader(statusCode)
		json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
		return
	}

	// Return updated vote counts
	voteCounts, err := h.service.GetVoteCounts(r.Context(), pollID)
	if err != nil {
		voteCounts = make(map[int]int)
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"vote_counts": voteCounts,
	})
}
