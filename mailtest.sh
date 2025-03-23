#!/usr/bin/env bash

TIMEWAIT=1

SMTP_SERVER="192.168.56.201"
SMTP_PORT="25"
SMTP_HELLO="example.com"

FROM_EMAIL="test1@example.com"
TO_EMAIL=("test1@example.com" "test2@example.com" "test3@example.com")
CC_EMAIL=("cc1@example.com")
BCC_EMAIL=("bcc1@example.com")

SUBJECT="Test Mail"
TO_HEADER=$(IFS=,; echo "${TO_EMAIL[*]}")
CC_HEADER=$(IFS=,; echo "${CC_EMAIL[*]}")

MESSAGE=$(cat <<EOF
Hello.

This is Test email.

EOF
)

send_line() {
  echo "$1"
  sleep ${TIMEWAIT} 
}

(
  sleep ${TIMEWAIT}
  send_line "HELO ${SMTP_HELLO}"
  send_line "MAIL FROM: ${FROM_EMAIL}"

  ALL_RECIPIENTS=($(printf "%s\n" "${TO_EMAIL[@]}" "${CC_EMAIL[@]}" "${BCC_EMAIL[@]}" | sort -u))
  for email in "${ALL_RECIPIENTS[@]}"; do
    send_line "RCPT TO: ${email}"
  done

  send_line "DATA"
  echo "From: ${FROM_EMAIL}"
  echo "To: ${TO_HEADER}"
  if [ -n "${CC_HEADER}" ]; then
    echo "Cc: ${CC_HEADER}"
  fi
  echo "Subject: ${SUBJECT}"
  echo ""
  echo "${MESSAGE}"
  echo ""

  send_line "."
  send_line "QUIT"
) | telnet ${SMTP_SERVER} ${SMTP_PORT}
