package schema

import (
	"time"

	"entgo.io/ent"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/edge"
)

type Vote struct {
	ent.Schema
}

func (Vote) Fields() []ent.Field {
	return []ent.Field{
		field.Int("poll_id"),
		field.Int("poll_option_id"),
		field.Int("user_id"),
		field.Time("created_at").Default(time.Now),
	}
}

func (Vote) Edges() []ent.Edge {
	return []ent.Edge{
		edge.To("poll", Poll.Type).Required().Unique().Field("poll_id"),
		edge.To("poll_option", PollOption.Type).Required().Unique().Field("poll_option_id"),
		edge.To("user", User.Type).Required().Unique().Field("user_id"),
	}
}
