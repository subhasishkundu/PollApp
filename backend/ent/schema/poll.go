package schema

import (
	"time"

	"entgo.io/ent"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/edge"
)

type Poll struct {
	ent.Schema
}

func (Poll) Fields() []ent.Field {
	return []ent.Field{
		field.String("title"),
		field.String("description"),
		field.Int("created_by"),
		field.Time("created_at").Default(time.Now),
	}
}

func (Poll) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("options", PollOption.Type).Ref("poll"),
		edge.From("votes", Vote.Type).Ref("poll"),
	}
}
