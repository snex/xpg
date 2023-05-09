#!/bin/bash

POST_DATA="{\"transaction\":{\"wallet_id\":$1,\"monero_tx_id\":\"$2\"}}"
/usr/bin/curl -s -X POST -H 'Content-Type: application/json' -d "$POST_DATA" http://127.0.0.1:5000/process_transaction
#/usr/bin/echo "/usr/bin/curl -X POST http://127.0.0.1:5000/process_tx/$1/$2"
