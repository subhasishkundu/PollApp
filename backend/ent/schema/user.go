package schema

import (
	"time"

	"entgo.io/ent"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/edge"
)

type User struct {
	ent.Schema
}

func (User) Fields() []ent.Field {
	return []ent.Field{
		field.String("username").Unique(),
		field.String("email").Unique(),
		field.String("password_hash"),
		field.Time("created_at").Default(time.Now),
	}
}

func (User) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("votes", Vote.Type).Ref("user"),
	}
}
