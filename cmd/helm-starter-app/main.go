package main

import (
	"github.com/replicatedhq/replicated-starter-helm/pkg/server"
	"log"
)

func main() {
	if err := server.Main(); err != nil {
		log.Fatal(err)
	}
}
