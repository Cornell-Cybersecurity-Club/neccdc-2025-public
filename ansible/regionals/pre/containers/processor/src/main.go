package main

import (
	"fmt"
	"net/http"
	"os"
	"time"
)

func main() {
	server := &http.Server{Addr: ":8080"}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		trialId := os.Getenv("TRIAL_ID")
		if trialId == "" {
			trialId = "Missing trial ID"
			fmt.Fprintf(w, "%s", trialId)
		} else {
			timestamp := os.Getenv("TIMESTAMP")
			fmt.Fprintf(w, "Processing (%s) trial %s", timestamp, trialId)
		}
	})

	http.HandleFunc("/metrics/status/processing", func(w http.ResponseWriter, r *http.Request) {
		location := os.Getenv("LOCATION")
		fmt.Fprintf(w, "%s", location)
	})

	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			fmt.Printf("ListenAndServe(): %s\n", err)
		}
	}()

	fmt.Println("Processing new records")
	time.Sleep(16 * time.Minute)

	if err := server.Close(); err != nil {
		fmt.Printf("Server Close(): %s\n", err)
	}

	fmt.Println("Processing completed successfully")
}
