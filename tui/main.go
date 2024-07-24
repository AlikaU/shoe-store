package main

// A simple example that shows how to render an animated progress bar. In this
// example we bump the progress by 25% every two seconds, animating our
// progress bar to its new target state.
//
// It's also possible to render a progress bar in a more static fashion without
// transitions. For details on that approach see the progress-static example.

import (
	"fmt"
	"os"
	"time"
	"net/http"
	"encoding/json"
	"io"
	"errors"
	"syscall"

	"log"
	"github.com/charmbracelet/bubbles/progress"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const (
	padding  = 2
	maxWidth = 80
	popularityURL = "http://localhost:3000/popularity"
	suggestionsURL = "http://localhost:3000/suggestions"
)

var helpStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#626262")).Render

func main() {
	f, err := tea.LogToFile("debug.log", "debug")
	if err != nil {
		fmt.Println("fatal:", err)
		os.Exit(1)
	}
	defer f.Close()

	m := model{
		// progress: progress.New(progress.WithDefaultGradient()),
	}

	if _, err := tea.NewProgram(m).Run(); err != nil {
		fmt.Println("Oh no!", err)
		os.Exit(1)
	}
}

type tickMsg time.Time

type model struct {
	progress progress.Model
	salesReport []shoeModelSales
	err error
}

type shoeModelSales struct {
	ShoeModel string `json:"model"`
	SalesPercent float64 `json:"sales_percent"`
}

func (m model) Init() tea.Cmd {
	// return tickCmd()
	return  tea.Batch(tickCheckPopularityCmd(), checkPopularity)
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

	// case tickMsg:
	// 	if m.progress.Percent() == 1.0 {
	// 		return m, tea.Quit
	// 	}

		// Note that you can also use progress.Model.SetPercent to set the
		// percentage value explicitly, too.
		// cmd := m.progress.IncrPercent(0.25)
        // make a random float between -0.5 and 0.5
        
        // ran := 0.5 - float64(time.Now().Nanosecond() % 100) / 100
        // cmd := m.progress.SetPercent(ran)
		// return m, tea.Batch(tickCmd(), cmd)
		return m, nil

	// FrameMsg is sent when the progress bar wants to animate itself
	case progress.FrameMsg:
		progressModel, cmd := m.progress.Update(msg)
		m.progress = progressModel.(progress.Model)
		return m, cmd

	case popularityMsg:
		m.err = nil
		m.salesReport = msg
		return m, tickCheckPopularityCmd()

	case errMsg:
        m.err = msg
        return m, tea.Quit

	case errNotConnectedMsg:
		m.err = msg
		return m, tickCheckPopularityCmd()


	default:
		return m, nil
	}
}

func (m model) View() string {
	// If there's an error, print it out and don't do anything else.
    if m.err != nil {
		if errors.As(m.err, &errNotConnectedMsg{}) {
			out := fmt.Sprint("\nWaiting to connect to server...")
			return out
		}
        return fmt.Sprintf("\nWe had some trouble: %v\n\n", m.err)
    }

	s := fmt.Sprintf("Shoe popularity report:\n")

	// pad := strings.Repeat(" ", padding)
	// return "\n" +
	// 	pad + m.progress.View() + "\n\n" +
	// 	pad + helpStyle("Press any key to quit")

	// When the server responds with a sales report, add it to the current line.
    if len(m.salesReport) != 0 {
        s += fmt.Sprintf("%v", m.salesReport)
    }
	return "\n" + s + "\n\n"
}


// commands


func tickCheckPopularityCmd() tea.Cmd {
	return tea.Tick(time.Second*2, func(t time.Time) tea.Msg {
		return checkPopularity()
	})
}

type errNotConnectedMsg struct {err error}
func (e errNotConnectedMsg) Error() string { return e.err.Error() }
type popularityMsg []shoeModelSales
type errMsg struct{ err error }
func (e errMsg) Error() string { return e.err.Error() }
func checkPopularity() tea.Msg {

    // Create an HTTP client and make a GET request.
    c := &http.Client{Timeout: 10 * time.Second}

	for {
		response, err := c.Get(popularityURL)
		if err != nil {
			if errors.Is(err, syscall.ECONNREFUSED) {
				return errNotConnectedMsg{fmt.Errorf("could not connect to server: %s", popularityURL)}
			} else {
				return errMsg{err}
			}
		}
		defer response.Body.Close()
	
		if response.StatusCode != http.StatusOK {
			return errMsg{fmt.Errorf("expected status 200 but got %v", response.Status)}
		}
	
		bodyBytes, err := io.ReadAll(response.Body)
		if err != nil {
			return errMsg{err}
		}
		log.Printf("body: %s\n", bodyBytes)
	
		// Parse into []shoeModelSales
		var shoeModelSales []shoeModelSales
		err = json.Unmarshal(bodyBytes, &shoeModelSales)
		if err != nil {
			return errMsg{err}
		}
		log.Printf("shoeModelSales: %+v\n", shoeModelSales)
		return popularityMsg(shoeModelSales)
	}
}
