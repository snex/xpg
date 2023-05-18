#!/bin/sh

POST_DATA="{\"transaction\":{\"wallet_id\":$1,\"monero_tx_id\":\"$2\"}}"
/usr/bin/curl -s -X POST -H 'Content-Type: application/json' -d "$POST_DATA" http://127.0.0.1:3000/api/v1/process_transaction
