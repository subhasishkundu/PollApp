package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/edge"
)

type PollOption struct {
	ent.Schema
}

func (PollOption) Fields() []ent.Field {
	return []ent.Field{
		field.Int("poll_id"),
		field.String("option_text"),
		field.Int("order").Default(0),
	}
}

func (PollOption) Edges() []ent.Edge {
	return []ent.Edge{
		edge.To("poll", Poll.Type).Required().Unique().Field("poll_id"),
		edge.From("votes", Vote.Type).Ref("poll_option"),
	}
}
