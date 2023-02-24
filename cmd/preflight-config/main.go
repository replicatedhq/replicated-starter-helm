package main

import (
	"fmt"
	"github.com/replicatedhq/replicated-starter-helm/pkg/server"
)

func main() {
	config, err := server.LoadConfig()
	if err != nil {
		fmt.Println(err)
	}

	_, err = server.NewHandlers(*config)
	if err != nil {
		fmt.Println(err)
	}
}
