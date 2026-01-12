package service

import (
	"context"
	"errors"
	"fmt"

	"pollapp/backend/ent"
	"pollapp/backend/ent/poll"
	"pollapp/backend/ent/polloption"
	"pollapp/backend/ent/user"
	"pollapp/backend/ent/vote"
)

type PollService struct {
	client *ent.Client
}

func NewPollService(client *ent.Client) *PollService {
	return &PollService{client: client}
}

func (s *PollService) CreatePoll(ctx context.Context, userID int, title, description string, options []string) (*ent.Poll, error) {
	if len(options) < 2 {
		return nil, errors.New("poll must have at least 2 options")
	}

	poll, err := s.client.Poll.Create().
		SetTitle(title).
		SetDescription(description).
		SetCreatedBy(userID).
		Save(ctx)
	if err != nil {
		return nil, err
	}

	// Create poll options
	for i, optionText := range options {
		if optionText == "" {
			continue // Skip empty options
		}
		_, err := s.client.PollOption.Create().
			SetPollID(poll.ID).
			SetOptionText(optionText).
			SetOrder(i).
			Save(ctx)
		if err != nil {
			return nil, fmt.Errorf("failed to create option %d: %w", i, err)
		}
	}

	return poll, nil
}

func (s *PollService) ListPolls(ctx context.Context) ([]*ent.Poll, error) {
	polls, err := s.client.Poll.Query().
		WithOptions().
		WithVotes().
		All(ctx)
	if err != nil {
		return nil, err
	}
	return polls, nil
}

func (s *PollService) GetPoll(ctx context.Context, id int) (*ent.Poll, error) {
	return s.client.Poll.Query().
		Where(poll.IDEQ(id)).
		WithOptions().
		WithVotes().
		Only(ctx)
}

func (s *PollService) GetVoteCounts(ctx context.Context, pollID int) (map[int]int, error) {
	options, err := s.client.PollOption.Query().
		Where(polloption.PollIDEQ(pollID)).
		All(ctx)
	if err != nil {
		return nil, err
	}

	counts := make(map[int]int)
	for _, option := range options {
		count, err := s.client.Vote.Query().
			Where(vote.PollOptionIDEQ(option.ID)).
			Count(ctx)
		if err != nil {
			return nil, err
		}
		counts[option.ID] = count
	}

	return counts, nil
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

func (s *PollService) Vote(ctx context.Context, pollID, pollOptionID, userID int) error {
	// Verify user exists
	_, err := s.client.User.Query().
		Where(user.IDEQ(userID)).
		Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return errors.New("user not found")
		}
		return err
	}

	// Verify poll option exists and belongs to the poll
	option, err := s.client.PollOption.Query().
		Where(polloption.IDEQ(pollOptionID), polloption.PollIDEQ(pollID)).
		Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return errors.New("poll option not found or doesn't belong to this poll")
		}
		return err
	}
	_ = option // Use option to avoid unused variable

	// Check if user already voted on this poll
	existing, err := s.client.Vote.Query().
		Where(vote.PollIDEQ(pollID), vote.UserIDEQ(userID)).
		Only(ctx)

	if err == nil && existing != nil {
		// Update existing vote to new option
		_, err = s.client.Vote.UpdateOneID(existing.ID).
			SetPollOptionID(pollOptionID).
			Save(ctx)
		return err
	}

	// Check if error is "not found" - that's expected for new votes
	if err != nil && !ent.IsNotFound(err) {
		return err
	}

	// Create new vote
	_, err = s.client.Vote.Create().
		SetPollID(pollID).
		SetPollOptionID(pollOptionID).
		SetUserID(userID).
		Save(ctx)
	return err
}
