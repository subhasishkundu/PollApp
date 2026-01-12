package handler

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/sql"
)

func NewEntClient(drv *sql.Driver) *ent.Client {
	return ent.NewClient(ent.Driver(drv))
}
