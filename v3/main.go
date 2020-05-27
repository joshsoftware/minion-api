package main

import (
	"bufio"
	"encoding/json"
	"log"
	"net"

	"gopkg.in/rethinkdb/rethinkdb-go.v6"
	r "gopkg.in/rethinkdb/rethinkdb-go.v6"
)

type Command struct {
	CommandID string `json:"command_id" gorethink:"command_id"`
}

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
			// {"action":"subscribe_command", "command_id":"914501cb-3071-4598-a0ab-6c876c949b1d", "server_id":"some-uuid"}
			// Used for keeping a persistent connection open to ask for new
			// commands to be run; agent will form a separate connection to
			// stream up the responses of those commands.
			// Necessary fields: command_id, server_id
			// TODO: Add some form of security key to verify that user can view
			// that particular command
			cid := payload["command_id"].(string)
			sid := payload["server_id"].(string)
			subscribeCommand(c, cid, sid)
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

func subscribeCommand(c net.Conn, commandID string, serverID string) {
	// TODO: Find some way to securely validate the server id is the one
	// corresponding to the command id.
	rdbOpts := rethinkdb.ConnectOpts{Database: "minion", Address: "localhost:28015"}
	rdb, err := r.Connect(rdbOpts)
	if err != nil {
		log.Println("subscribeCommand: ", err)
	}
	cursor, err := r.DB("minion").Table("commands").Get(commandID).Run(rdb)
	if err != nil {
		log.Println("subscribeCommand: ", err)
	}
	defer cursor.Close()
	var cmd interface{}
	err = cursor.One(&cmd)
	if err != nil {
		log.Println("subscribeCommand:", err)
	}

	cmdJSON, _ := json.Marshal(cmd)
	log.Println(string(cmdJSON))
}
