package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"time"

	"howett.net/plist"
)

var bartenderSetting = `Library/Preferences/com.surteesstudios.Bartender.plist`

func main() {
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}

	bartenderSetting = fmt.Sprintf("%s/%s", home, bartenderSetting)
	f, err := os.OpenFile(bartenderSetting, os.O_RDWR, 0644)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	m := make(map[string]any)
	decoder := plist.NewDecoder(f)
	if err := decoder.Decode(&m); err != nil {
		log.Fatalf("failed to decode plist: %v", err)
	}

	now := time.Now().UTC()
	if _, ok := m["trial5Start"]; ok {
		m["trial5Start"] = now
		m["NSWindow Frame SU5AlertMessages"] = now.UnixMilli()
	}

	if _, err := f.Seek(0, 0); err != nil {
		log.Fatal(err)
	}
	if err := f.Truncate(0); err != nil {
		log.Fatal(err)
	}

	encoder := plist.NewEncoder(f)
	if err := encoder.Encode(m); err != nil {
		log.Fatalf("failed to encode plist: %v", err)
	}

	log.Println("Done")

	if err := exec.Command("pkill", `Bartender 5`).Run(); err != nil {
		log.Printf("failed to kill bartender: %v", err)
	}

	time.Sleep(1 * time.Second)

	if err := exec.Command("open", "-a", `Bartender 5`).Run(); err != nil {
		log.Printf("failed to open bartender: %v", err)
	}
}
