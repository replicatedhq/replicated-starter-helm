package server

type Handlers struct {
	ServerConfig
}

func NewHandlers(config ServerConfig) (*Handlers, error) {

	handlers := &Handlers{
		ServerConfig: config,
	}

	return handlers, nil
}
