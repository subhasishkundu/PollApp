package schema

import (
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
		field.Int("user_id"),
		field.Bool("is_upvote").Default(true),
		field.Time("created_at").DefaultNow(),
	}
}

func (Vote) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("poll", Poll.Type).Ref("votes").Field("poll_id").Required(),
		edge.From("user", User.Type).Ref("votes").Field("user_id").Required(),
	}
}
