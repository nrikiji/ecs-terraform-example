package models

import (
	"database/sql"
	"log"
	"os"

	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

var Db *sql.DB

func init() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Fatalln(err)
	}

	dbHost := os.Getenv("MYSQL_HOST")
	dbUser := os.Getenv("MYSQL_USER")
	dbPass := os.Getenv("MYSQL_PASSWORD")

	db, err := sql.Open("mysql", dbUser+":"+dbPass+"@tcp("+dbHost+":3306)/test?parseTime=true")
	if err != nil {
		log.Fatalln(err)
	}
	Db = db
}
