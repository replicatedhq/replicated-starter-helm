package main

import (
	"fmt"
	"github.com/pkg/errors"
	"github.com/replicatedhq/replicated-starter-helm/pkg/server"
)

func main() {
	config, err := server.LoadConfig()
	if err != nil {
		fmt.Println(err)
	}

	handlers, err := server.NewHandlers(*config)
	if err != nil {
		fmt.Println(err)
	}

	_, err = handlers.GetGitHubUser()
	if err != nil {
		fmt.Println(errors.Wrap(err, "get github user"))
	}

}
