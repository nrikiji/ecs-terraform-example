package main

import (
	"example/app/controllers"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	controllers.StartServer()
}
