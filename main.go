/*
 Copyright 2018 Marcos Rafael Kaissi Barbosa

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

package main

import (
	"fmt"
	"log"
	"net/http"
	"os/exec"
	"bytes"
	"os"
)

func main() {
	http.HandleFunc("/liveness", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		w.Write([]byte("ok"))
	})
	http.HandleFunc("/readiness", func(w http.ResponseWriter, r *http.Request) {
		cmd := exec.Command(os.Getenv("HEALTH_READINESS_FILE"))
		var out bytes.Buffer
		cmd.Stdout = &out
		err := cmd.Run()
		if err != nil {
			w.WriteHeader(500)
			w.Write([]byte(fmt.Sprintf("error: %v", err.Error())))
		} else {
			w.WriteHeader(200)
			w.Write([]byte("ok"))
		}
	})
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%v", os.Getenv("HEALTH_PORT_TARGET")), nil))
}
