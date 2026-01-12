package schema

import (
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
		field.Time("created_at").DefaultNow(),
	}
}

func (Poll) Edges() []ent.Edge {
	return []ent.Edge{
		edge.To("votes", Vote.Type),
	}
}
