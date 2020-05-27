package main

import (
	"bufio"
	"encoding/json"
	"log"
	"net"
)

func main() {
	log.SetFlags(0)

	ln, err := net.Listen("tcp", ":9000")
	if err != nil {
		log.Println("net.Listen: ", err)
	}

	defer ln.Close()

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Println("ln.Accept: ", err)
		}
		go handleConn(conn)
	}
}

func handleConn(c net.Conn) {
	scanner := bufio.NewScanner(c)
	for scanner.Scan() { // TODO: Maybe we base64 encode/decode text for "compression"?
		msg := scanner.Text()
		log.Println("Received: ", msg) // .Scan() seems to be for every line

		var payload map[string]interface{}
		err := json.Unmarshal([]byte(msg), &payload)
		if err != nil {
			log.Println("json.Unmarshal: ", err)
		}
		switch payload["action"] {
		case "subscribe_command":
			// Used for keeping a persistent connection open to ask for new
			// commands to be run; agent will form a separate connection to
			// stream up the responses of those commands.
			// Necessary fields: command_id, server_id
			// TODO: Add some form of security key to verify that user can view
			// that particular command
		case "stream_command_response":
			// When streaming back stdout and stderr from an issued command
			// Need: command_id, stderr_line, stdout_line, at
		case "stream_log":
			// When streaming a log file back to the server
			// Necessary fields: server_id, log_path, at, log_line
		case "stream_metrics":
			// When streaming things like free memory, disk i/o, cpu usage, etc. back to the server
			// Needed: metric, value, server_id
		case "register":
			// When a server first comes online, so it can get cryptographic keys for validating
			// commands and such in the future
			// Needed: server_id, api_key
		case "bye":
			// Used when a server logs out, like an orderly shutdown.
			// Need: server_id, reason (may be blank)
		case "hi":
			// Used when an agent starts back up after already being registered
			// This is to report that it's back online forllowing, say, a reboot
			// Needed: server_id
		default:
			// Do nothing
		}
	}
	return
}
