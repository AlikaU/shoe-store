package main

// A very quick go at a terminal UI for the shoe store dashboard, not meant to be nice or anything.

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"syscall"
	"time"

	"log"

	"github.com/charmbracelet/bubbles/progress"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const (
	padding         = 2
	maxWidth        = 80
	popularityPath  = "/popularity"
	suggestionsPath = "/suggestions"
)

var shoeAPIAddress = os.Getenv("SHOE_API_ADDRESS")
var helpStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#727272")).Render
var pad = strings.Repeat(" ", padding)

func main() {
	f, err := setupLogging()
	if err != nil {
		fmt.Println("fatal:", err)
		os.Exit(1)
	}
	defer f.Close()
	log.Print("\n\n\nStarting up...")

	if shoeAPIAddress == "" {
		shoeAPIAddress = "http://localhost:3000"
	}

	m := model{}

	if _, err := tea.NewProgram(m).Run(); err != nil {
		fmt.Println("Oh no!", err)
		os.Exit(1)
	}
}

func setupLogging() (*os.File, error) {
	// Open the log file in write mode to clear it
	f, err := os.OpenFile("debug.log", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0666)
	if err != nil {
		return nil, err
	}
	f.Close()

	return tea.LogToFile("debug.log", "debug")
}

type model struct {
	progress         progress.Model
	popularityReport popularityReport
	suggestion       string
	err              error
}

type popularityReport struct {
	shoeModelSales []shoeModelSales
}

type shoeModelSales struct {
	ShoeModel    string  `json:"model"`
	SalesPercent float64 `json:"sales_percent"`
}

func (m model) Init() tea.Cmd {
	return tea.Batch(
		tickCheckPopularityCmd(), checkPopularity,
		tickCheckSuggestionsCmd(), checkSuggestions,
	)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		return m, tea.Quit

	case tea.WindowSizeMsg:
		m.progress.Width = msg.Width - padding*2 - 4
		if m.progress.Width > maxWidth {
			m.progress.Width = maxWidth
		}
		return m, nil

	case popularityMsg:
		m.err = nil
		m.popularityReport.shoeModelSales = msg
		return m, tickCheckPopularityCmd()

	case suggestionMsg:
		m.err = nil
		m.suggestion = string(msg)
		return m, tickCheckSuggestionsCmd()

	case errMsg:
		m.err = msg
		return m, tea.Quit

	case errNotConnectedMsg:
		m.err = errNotConnected{err: msg.err}
		log.Printf("Could not connect to server: %v, retrying...", msg.err)
		return m, tickCheckPopularityCmd()

	default:
		return m, nil
	}
}

func (m model) View() string {
	// If there's an error, print it out and don't do anything else.
	popularityReport := m.popularityReport.View()
	if m.err != nil {
		if _, ok := m.err.(errNotConnected); ok {
			popularityReport = fmt.Sprint("\n" + pad + "Waiting to connect to server...")
		} else {
			return fmt.Sprintf("\nWe had some trouble: %v\n\n", m.err)
		}
	}

	suggestion := ""
	if m.suggestion != "" {
		suggestion = fmt.Sprintf("%s\n\n", wrapText("Suggestion: "+m.suggestion, maxWidth-2*padding))
	}

	return "\n" +
		asciiArt + "\n\n" +
		pad + "Welcome to the shoe store dashboard!\n\n" +
		pad + "Here you can see the popularity of different shoe models. \n" +
		pad + popularityReport + "\n\n" +
		pad + suggestion + "\n\n" +
		pad + helpStyle("Press any key to quit")
}

func (p popularityReport) View() string {
	maxBarWidth := 59
	pad := strings.Repeat(" ", 2)

	maxSalesPercent := 0.0
	for _, sale := range p.shoeModelSales {
		if sale.SalesPercent > maxSalesPercent {
			maxSalesPercent = sale.SalesPercent
		}
	}

	result := "\n"
	result += pad + fmt.Sprintf("%-10s %9s\n", "Model", "% of sales")
	result += pad + fmt.Sprintf(strings.Repeat("-", maxWidth-2)+"\n")

	for _, sale := range p.shoeModelSales {
		barLength := int((sale.SalesPercent / maxSalesPercent) * float64(maxBarWidth))
		bar := strings.Repeat("|", barLength)
		result += pad + fmt.Sprintf("%-10s %-59s %6.2f%%\n", sale.ShoeModel, bar, sale.SalesPercent)
	}
	return result
}

type errNotConnected struct{ err error }

func (e errNotConnected) Error() string { return e.err.Error() }

type errNotConnectedMsg struct{ err error }

func (e errNotConnectedMsg) Error() string { return e.err.Error() }

type errMsg struct{ err error }

func (e errMsg) Error() string { return e.err.Error() }

type popularityMsg []shoeModelSales

type suggestionMsg string

// commands

func tickCheckSuggestionsCmd() tea.Cmd {
	return tea.Tick(time.Second*5, func(t time.Time) tea.Msg {
		return checkSuggestions()
	})
}

func checkSuggestions() tea.Msg {
	bodyBytes, errM := sendGetRequesst(shoeAPIAddress + suggestionsPath)
	if errM != nil {
		return errM
	}
	var suggestionsResponse suggestionsResponse
	err := json.Unmarshal(bodyBytes, &suggestionsResponse)
	if err != nil {
		return errMsg{err}
	}
	return suggestionMsg(suggestionsResponse.Suggestion)
}

type suggestionsResponse struct {
	Suggestion string `json:"suggestion"`
}

func tickCheckPopularityCmd() tea.Cmd {
	return tea.Tick(time.Second*1, func(t time.Time) tea.Msg {
		return checkPopularity()
	})
}

func checkPopularity() tea.Msg {
	bodyBytes, errM := sendGetRequesst(shoeAPIAddress + popularityPath)
	if errM != nil {
		return errM
	}

	var shoeModelSales []shoeModelSales
	err := json.Unmarshal(bodyBytes, &shoeModelSales)
	if err != nil {
		return errMsg{err}
	}
	return popularityMsg(shoeModelSales)
}

func sendGetRequesst(url string) ([]byte, tea.Msg) {
	c := &http.Client{Timeout: 10 * time.Second}
	response, err := c.Get(url)
	if err != nil {
		if errors.Is(err, syscall.ECONNREFUSED) {
			time.Sleep(5 * time.Second)
			return nil, errNotConnectedMsg{err: fmt.Errorf("could not connect to server: %s", url)}
		} else {
			return nil, errMsg{err}
		}
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return nil, errMsg{fmt.Errorf("expected status 200 but got %v", response.Status)}
	}

	bodyBytes, err := io.ReadAll(response.Body)
	if err != nil {
		return nil, errMsg{err}
	}
	return bodyBytes, nil
}

func wrapText(text string, lineWidth int) string {
	if len(text) <= lineWidth {
		return text
	}

	wrappedText := ""
	words := strings.Fields(text)
	currentLine := ""

	for _, word := range words {
		if len(currentLine)+len(word)+1 > lineWidth {
			wrappedText += currentLine + "\n" + pad
			currentLine = word
		} else {
			if currentLine != "" {
				currentLine += " "
			}
			currentLine += word
		}
	}

	wrappedText += currentLine
	return wrappedText
}

var asciiArt = `      _                      _                 
     | |                    | |                
  ___| |__   ___   ___   ___| |_ ___  _ __ ___ 
 / __| '_ \ / _ \ / _ \ / __| __/ _ \| '__/ _ \
 \__ \ | | | (_) |  __/ \__ \ || (_) | | |  __/
 |___/_| |_|\___/ \___| |___/\__\___/|_|  \___|
                                               
                                               `
