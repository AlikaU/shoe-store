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
	"strings"

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

	m := model{
		// progress: progress.New(progress.WithDefaultGradient()),
	}

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

type tickMsg time.Time

type model struct {
	progress progress.Model
	popularityReport popularityReport
	err error
}

type popularityReport struct {
	shoeModelSales []shoeModelSales
}

type shoeModelSales struct {
	ShoeModel string `json:"model"`
	SalesPercent float64 `json:"sales_percent"`
}

func (m model) Init() tea.Cmd {
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
		m.popularityReport.shoeModelSales = msg
		return m, tickCheckPopularityCmd()

	case errMsg:
        m.err = msg
        return m, tea.Quit

	case errNotConnectedMsg:
		m.err = errNotConnected{err: msg.err}
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
			popularityReport = fmt.Sprint("Waiting to connect to server...")
		} else {
			return fmt.Sprintf("\nWe had some trouble: %v\n\n", m.err)
		}
    }

	return "\n" +
  	`         __                  __              
    ___ / /  ___  ___   ___ / /____  _______ 
   (_-</ _ \/ _ \/ -_) (_-</ __/ _ \/ __/ -_)
  /___/_//_/\___/\__/ /___/\__/\___/_/  \__/ 
                                           ` + "\n\n" +
		pad + "Welcome to the shoe store dashboard!\n\n" +
		pad + "This report lets you see the popularity of different shoe models. \n" +
		pad + popularityReport + "\n\n" +
		pad + helpStyle("Press any key to quit")
}

func (p popularityReport) View() string {
	// result := "\n"
	// result += pad + fmt.Sprintf("%-10s %9s\n", "Model", "% of sales")
	// result += pad + fmt.Sprintf("%-10s %9s\n", strings.Repeat("-", 10), strings.Repeat("-", 9))
	
	// log.Printf("shoeModelSales: %v", p.shoeModelSales)
	// for _, sale := range p.shoeModelSales {
	// 	result += pad + fmt.Sprintf("%-10s %6.2f%%\n", sale.ShoeModel, sale.SalesPercent)
	// }
	// return result
	// maxWidth := 50 // Maximum width for the bar
	// pad := strings.Repeat(" ", 2)
	
	// // Find the maximum sales percentage
	// maxSalesPercent := 0.0
	// for _, sale := range p.shoeModelSales {
	// 	if sale.SalesPercent > maxSalesPercent {
	// 		maxSalesPercent = sale.SalesPercent
	// 	}
	// }

	// result := "\n"
	// result += pad + fmt.Sprintf("%-10s %9s %s\n", "Model", "% of sales", "Bar")
	// result += pad + fmt.Sprintf("%-10s %9s %s\n", strings.Repeat("-", 10), strings.Repeat("-", 9), strings.Repeat("-", maxWidth))

	// log.Printf("shoeModelSales: %v", p.shoeModelSales)
	// for _, sale := range p.shoeModelSales {
	// 	barLength := int((sale.SalesPercent / maxSalesPercent) * float64(maxWidth))
	// 	bar := strings.Repeat("|", barLength)
	// 	result += pad + fmt.Sprintf("%-10s %6.2f%% %s\n", sale.ShoeModel, sale.SalesPercent, bar)
	// }
	// return result
	barWidth := 59 // Maximum width for the bar
	pad := strings.Repeat(" ", 2)
	
	// Find the maximum sales percentage
	maxSalesPercent := 0.0
	for _, sale := range p.shoeModelSales {
		if sale.SalesPercent > maxSalesPercent {
			maxSalesPercent = sale.SalesPercent
		}
	}

	result := "\n"
	result += pad + fmt.Sprintf("%-10s %9s\n", "Model", "% of sales")
	result += pad + fmt.Sprintf(strings.Repeat("-", maxWidth - 2) + "\n")

	log.Printf("shoeModelSales: %v", p.shoeModelSales)
	for _, sale := range p.shoeModelSales {
		barLength := int((sale.SalesPercent / maxSalesPercent) * float64(barWidth))
		bar := strings.Repeat("|", barLength)
		result += pad + fmt.Sprintf("%-10s %-59s %6.2f%%\n", sale.ShoeModel, bar, sale.SalesPercent)
	}
	return result
}


// commands


func tickCheckPopularityCmd() tea.Cmd {
	return tea.Tick(time.Second*1, func(t time.Time) tea.Msg {
		return checkPopularity()
	})
}

type errNotConnected struct {err error}
func (e errNotConnected) Error() string { return e.err.Error() }

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
				return errNotConnectedMsg{err: fmt.Errorf("could not connect to server: %s", popularityURL)}
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
	
		// Parse into []shoeModelSales
		var shoeModelSales []shoeModelSales
		err = json.Unmarshal(bodyBytes, &shoeModelSales)
		if err != nil {
			return errMsg{err}
		}
		return popularityMsg(shoeModelSales)
	}
}
