package server

import (
	"github.com/codingconcepts/env"
	"github.com/pkg/errors"
	"net/url"
)

// ServerConfig is the environment configuration for the backend process
// it includes the client config which is served to the frontend on page load
type ServerConfig struct {
	GinAddress string `env:"GIN_ADDRESS"`
	GitVersion string `env:"GIT_VERSION"`

	// StaticDir defines where frontend assets should be served from
	// This is designed for production builds where the Gin server serves both the
	// frontend routes from /* and the api routes from /api/*
	StaticDir string `env:"STATIC_DIR"`

	// ProxyFrontend specifies a local URL to use for frontend assets
	// this should only be used when developing locally
	ProxyFrontend    string `env:"PROXY_FRONTEND"`
	ProxyFrontendURL *url.URL

	// frontend / UI settings
	Title         string `json:"title" env:"FORM_TITLE"`
	IntroMarkdown string `json:"introMarkdown" env:"FORM_INTRO_MARKDOWN"`

	// License creation options
	GitHubPersonalAccessToken string `env:"GITHUB_PAT"`
}

func DefaultConfig() ServerConfig {
	return ServerConfig{
		GinAddress:    ":8888",
		ProxyFrontend: "http://localhost:3000",

		Title:         "GitHub UserView",
		IntroMarkdown: "This app will show your github login details",
	}

}

func LoadConfig() (*ServerConfig, error) {

	config := DefaultConfig()

	if err := env.Set(&config); err != nil {
		return nil, errors.Wrap(err, "load env config")
	}

	if err := config.parseConfig(); err != nil {
		return nil, errors.Wrap(err, "parse config")
	}

	return &config, nil
}

func (config *ServerConfig) parseConfig() error {
	if config.ProxyFrontend != "" {
		parsed, err := url.Parse(config.ProxyFrontend)
		if err != nil {
			return errors.Wrap(err, "parse ProxyFrontend URL")
		}
		config.ProxyFrontendURL = parsed
	}

	return nil
}
