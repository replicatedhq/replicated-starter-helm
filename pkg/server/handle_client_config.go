package server

import (
	"github.com/gin-gonic/gin"
	"github.com/pkg/errors"
	"io"
	"net/http"
)

type ClientConfig struct {
	Title         string `json:"title"`
	IntroMarkdown string `json:"introMarkdown"`
	GitHubUser    string `json:"gitHubUser"`
}

func (h *Handlers) ClientConfig(c *gin.Context) {

	json, err := h.GetGitHubUser()
	if err != nil {
		c.JSON(200, ClientConfig{
			Title:         h.ServerConfig.Title,
			IntroMarkdown: h.ServerConfig.IntroMarkdown,
			GitHubUser:    `"Invalid GitHub Personal Access Token"`,
		})
		return
	}

	c.JSON(200, ClientConfig{
		Title:         h.ServerConfig.Title,
		IntroMarkdown: h.ServerConfig.IntroMarkdown,
		GitHubUser:    json,
	})
}

func (h *Handlers) GetGitHubUser() (string, error) {

	token := h.ServerConfig.GitHubPersonalAccessToken

	request, err := http.NewRequest("GET", "https://api.github.com/user?pretty", nil)

	if err != nil {
		return "", errors.Wrap(err, "create request")
	}

	request.Header.Set("Accept", "application/vnd.github+json")
	request.Header.Set("Authorization", "Bearer "+token)
	request.Header.Set("X-GitHub-Api-Version", "2022-11-28")

	resp, err := http.DefaultClient.Do(request)
	if err != nil {
		return "", errors.Wrap(err, "send request")
	}

	defer resp.Body.Close()

	if resp.StatusCode != 200 {

		json, err := io.ReadAll(resp.Body)
		if err != nil {
			return "", errors.Errorf("status code %d", resp.StatusCode)
		}
		return "", errors.Errorf("status code %d: %s", resp.StatusCode, string(json))
	}

	json, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", errors.Wrap(err, "read body")
	}

	return string(json), nil
}
