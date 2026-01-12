package handler

import (
	"pollapp/backend/ent"
	"entgo.io/ent/dialect/sql"
)

func NewEntClient(drv *sql.Driver) *ent.Client {
	return ent.NewClient(ent.Driver(drv))
}
