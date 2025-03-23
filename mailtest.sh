#!/bin/bash

TIMEWAIT=1

SMTP_SERVER="localhost"
SMTP_PORT="25"
SMTP_HELLO="example.com"

FROM_EMAIL="test1@example.com"
TO_EMAIL="test1@example.com test2@example.com test3@example.com"
CC_EMAIL="cc1@example.com cc2@example.com cc3@example.com"
BCC_EMAIL="bcc1@example.com bcc2@example.com bcc3@example.com"

SUBJECT="Test Mail"
TO_HEADER=$(echo ${TO_EMAIL} | sed 's/ /, /g')
CC_HEADER=$(echo ${CC_EMAIL} | sed 's/ /, /g')

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

  for email in ${TO_EMAIL}; do
    send_line "RCPT TO: ${email}"
  done
  if [ -n "${CC_EMAIL}" ]; then
    for email in ${CC_EMAIL}; do
      send_line "RCPT TO: ${email}"
    done
  fi
  if [ -n "${BCC_EMAIL}" ]; then
    for email in ${BCC_EMAIL}; do
      send_line "RCPT TO: ${email}"
    done
  fi

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
