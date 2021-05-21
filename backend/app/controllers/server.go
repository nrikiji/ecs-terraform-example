package controllers

import (
	"example/app/models"
	"log"
	"net/http"

	"github.com/rs/cors"
)

func hello(w http.ResponseWriter, r *http.Request) {
	log.Println("start hello")

	test, err := models.GetTest()
	if err != nil {
		RespondError(w, http.StatusInternalServerError, err.Error())
	} else {
		RespondJSON(w, http.StatusOK, test)
	}

	log.Println("finish hello")
}

func StartServer() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", hello)
	handler := cors.Default().Handler(mux)
	http.ListenAndServe(":80", handler)
}
