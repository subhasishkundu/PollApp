package service

import (
	"context"
	"errors"

	"pollapp/backend/internal/ent"
	"pollapp/backend/internal/ent/poll"
	"pollapp/backend/internal/ent/vote"
)

type PollService struct {
	client *ent.Client
}

func NewPollService(client *ent.Client) *PollService {
	return &PollService{client: client}
}

func (s *PollService) CreatePoll(ctx context.Context, userID int, title, description string) (*ent.Poll, error) {
	return s.client.Poll.Create().
		SetTitle(title).
		SetDescription(description).
		SetCreatedBy(userID).
		Save(ctx)
}

func (s *PollService) ListPolls(ctx context.Context) ([]*ent.Poll, error) {
	return s.client.Poll.Query().
		WithVotes().
		All(ctx)
}

func (s *PollService) GetPoll(ctx context.Context, id int) (*ent.Poll, error) {
	return s.client.Poll.Query().
		Where(poll.IDEQ(id)).
		WithVotes().
		Only(ctx)
}

func (s *PollService) UpdatePoll(ctx context.Context, id, userID int, title, description string) (*ent.Poll, error) {
	p, err := s.client.Poll.Query().
		Where(poll.IDEQ(id)).
		Only(ctx)
	if err != nil {
		return nil, err
	}

	if p.CreatedBy != userID {
		return nil, errors.New("unauthorized")
	}

	return s.client.Poll.UpdateOneID(id).
		SetTitle(title).
		SetDescription(description).
		Save(ctx)
}

func (s *PollService) DeletePoll(ctx context.Context, id, userID int) error {
	p, err := s.client.Poll.Query().
		Where(poll.IDEQ(id)).
		Only(ctx)
	if err != nil {
		return err
	}

	if p.CreatedBy != userID {
		return errors.New("unauthorized")
	}

	return s.client.Poll.DeleteOneID(id).Exec(ctx)
}

func (s *PollService) Upvote(ctx context.Context, pollID, userID int) error {
	return s.vote(ctx, pollID, userID, true)
}

func (s *PollService) Downvote(ctx context.Context, pollID, userID int) error {
	return s.vote(ctx, pollID, userID, false)
}

func (s *PollService) vote(ctx context.Context, pollID, userID int, isUpvote bool) error {
	existing, err := s.client.Vote.Query().
		Where(vote.PollIDEQ(pollID), vote.UserIDEQ(userID)).
		Only(ctx)

	if err == nil {
		// Update existing vote
		return s.client.Vote.UpdateOneID(existing.ID).
			SetIsUpvote(isUpvote).
			Save(ctx)
	}

	// Create new vote
	_, err = s.client.Vote.Create().
		SetPollID(pollID).
		SetUserID(userID).
		SetIsUpvote(isUpvote).
		Save(ctx)
	return err
}
