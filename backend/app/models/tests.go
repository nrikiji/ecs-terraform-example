package models

import "time"

type Test struct {
	CreatedAt *time.Time
}

func GetTest() (test Test, err error) {
	test = Test{}
	sql := "select created_at from test"
	err = Db.QueryRow(sql).Scan(&test.CreatedAt)
	return test, err
}
