#!/bin/bash

. ./monzovars

penceToGbp(){
	<<<$1 sed -re 's/^([0-9]+)([0-9][0-9])$/\1.\2 GBP/'
}
case $1 in
	"balance"|"bal"|b)
		penceToGbp $(http https://api.monzo.com/balance "account_id==$MZ_AID" "Authorization: Bearer $MZ_TKN" | jq '.balance')
		;;
	"transactions"|"trans"|t)
		if [[ "x$3" = "x" ]]; then
			# date was not specified
			STARTDATE=$(date +%F -d 'last month')
		else
			STARTDATE="$3"
		fi

		http \
			https://api.monzo.com/transactions \
			"Authorization: Bearer $MZ_TKN" \
			"account_id==$MZ_AID" \
			"since==$STARTDATE" \
		| jq -r 'def roundit: .*100.0 + 0.5|floor/100.0; .transactions| "\( .[].settled ), \( .[].amount/100 ), \( .[].currency ), \( .[].description )"' \
		| tr -s ' ' \
		| awk -F, 'BEGIN { printf "%24s | %15s | %s \n", "Date updated", "Amount", "Beneficiary" } {printf "%24s | %10s %3s | %s \n", $1, sprintf("%.2f",$2), $3, $4 }'
		;;
	"feed"|"f")
		case "$2" in
			"add")
				http --form POST https://api.monzo.com/feed \
					"Authorization: Bearer $MZ_TKN" \
					"account_id=$MZ_AID" \
					"type=basic" \
					"url=https://tyjgr.com" \
					"params[title]=$3" \
					"params[image_url]=https://tyjgr.com/img/isp.png" \
					"params[background_color]=#213310" \
					"params[body]=$4"
				;;
		esac
		;;
esac
