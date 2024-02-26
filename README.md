# XPG Monero Payment Gateway
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/snex/xpg/rubyonrails.yml)
![GitHub](https://img.shields.io/github/license/snex/xpg)

Donate XMR - 481eZedQWukX66WAjAK2KJ8cgnnRJhzHKQvJdX8cJrPqbgJhicrf7reEv7F5EsT5BUaQ41AkBo1XBTHH4dCEY3kc4nY6it5

## Prerequisites
You will need a Monero node. It is strongly advised for privacy reasons that you run your own, however a public node will work. You do not need a full node, a pruned node will work.

## Installation
```bash
wget https://raw.githubusercontent.com/snex/xpg/master/docker-compose.yml
wget https://raw.githubusercontent.com/snex/xpg/master/nginx.conf
wget https://raw.githubusercontent.com/snex/xpg/master/.env.docker.example
```

Edit the .env.docker.example file with the desired values, rename it to .env.docker, then run
```
docker compose up
```

The app will be available at http://localhost:3000/admin/wallets. You should ensure that this is never reachable via the internet, as the app currently assumes all network requests are authorized. There are plans to add HMAC auth in the future, but for now, just keep the app on the same local network as your web store and do not permit any outside network access to it.

From the web portal, you can set up any wallets you want. These will be view only wallets, so there is never a risk of losing your funds even if XPG is compromised.

## Usage
When a customer clicks on a "Pay With Monero" button at checkout (grab one [here](https://www.themonera.art/2017/09/22/monero-promotional-graphics-badges-and-stickers-for-websites/)), your app must create an invoice on XPG by performing an HTTP POST to http://localhost:3000/api/v1/invoice with the following JSON body:
```json
{
  "invoice": {
    "wallet_name":   "[WALLET_NAME]",
    "amount":        [AMOUNT],
    "expires_at":    "[EXPIRES_AT]",
    "external_id":   "[EXTERNAL_ID]",
    "callback_url":  "[CALLBACK_URL]"
  }
}
```
* WALLET_NAME is the wallet name that you created on the XPG web portal.
* AMOUNT is the exact integer amount in piconeros, not XMR. It is equal to XMR * 1e12.
* EXPIRES_AT is optional if your wallet has a default_expiry_ttl defined. Otherwise it must be a timestamp in ISO-8601 format.
* EXTERNAL_ID uniquely identifies this invoice to both XPG and your web store. It is safe to use the customer's order number.
* CALLBACK_URL is a unique callback URL that XPG will ping when a payment is witnessed on the Monero network and when that payment is confirmed.

IMPORTANT! The callback URL must be unique and it must not be associated in any way with any publicly known info. This could lead to your app being tricked by a forged request into thinking the invoice is paid when it is not. You should generate these URLs by creating a nonce, temporarily storing it into the database with the customer order, and then deleting that nonce when the payment is confirmed.

The response will be in the following JSON format:
```json
{
  "wallet_name":            "[WALLET_NAME]",
  "amount":                 "[AMOUNT]",
  "external_id":            "[EXTERNAL_ID]",
  "callback_url":           "[CALLBACK_URL]",
  "id":                     "[ID]",
  "expires_at":             "[EXPIRES_AT]",
  "incoming_address":       "[INCOMING_ADDRESS]",
  "payment_id":             "[PAYMENT_ID]",
  "estimated_confirm_time": [ESTIMATED_CONFIRM_TIME],
  "qr_code":                "[QR_CODE_URL]"
}
```
* AMOUNT is a string and is in XMR, and should have " XMR" after the amount. This is for display directly to the customer.
* EXTERNAL_ID and CALLBACK_URL are the values you supplied in the original POST request.
* ID is the unique ID generated by XPG.
* EXPIRES_AT is either the value you supplied, or the default value generated by XPG if you left it blank.
* INCOMING_ADDRESS is the Monero address that the customer must submit payment to. This is for display directly to the customer.
* PAYMENT_ID is the payment ID that the customer can fill out when they submit the payment. Since INCOMING_ADDRESS is an integrated address, this shouldn't be necessary, but it is good to display to the customer anyway.
* ESTIMATED_CONFIRM_TIME is the estimated time in seconds that it will take to confirm the customer's payment once it has been witnessed. This number is based on the AMOUNT on the invoice. Larger amounts require more confirmations. A customer can submit multiple payments instead of one, and as long as they add up to the AMOUNT, the invoice will be considered paid. By submitting multiple payments, a customer can reduce their confirmation time at the expense of multiple fees to the Monero network.
* QR_CODE_URL is an SVG file that XPG creates for the invoice. If the customer has a wallet that supports QR codes, this is the ideal way for them to pay since it does not allow for the possibility of mistakes. This is for display directly to the customer.

When a payment is seen on the Monero network, XPG will send a POST to the callback URL with the following JSON body:
```json
{
  "status":   "payment_witnessed",
  "payments": [
    {
      "amount":                  [AMOUNT],
      "confirmations":           [CONFIRMATIONS],
      "necessary_confirmations": [NECESSARY_CONFIRMATIONS]
    }
  ]
 }
```
* AMOUNT is an integer and is the number of piconeros in the payment.
* CONFIRMATIONS is an integer and represents the number of confirmations on the Monero network that have been seen.
* NECESSARY_CONFIRMATIONS is the number of confirmations on the Monero network that are required before this payment is considered confirmed. It should never go above 10.

When all payments on an invoice are confirmed, XPG will send a POST to the callback URL with the following JSON body:
```json
{
  "status": "payment_complete"
}
```
At this point, you should treat the customer's order as fully paid.

## Other
XPG does not store any records or logs long term. It deletes invoices that are either expired or fully paid. If you fill out the email ENV vars, it will email you in the following situations:

* A payment with no identifiable invoice was witnessed. This could happen if the customer paid after the invoice expired, or you re-used an incoming address for something else (you should not do the latter).
* A customer overpaid on an invoice. If the customer pays too much, the normal flow will happen and the invoice will be treated as fully paid. The email is for your convenience if you need to issue any kind of refund.
* An invoice is partially paid but is about to be deleted because it has expired. If a customer only partially pays what they owe, and then the invoice expires, it will still be marked for deletion.
