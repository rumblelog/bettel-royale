#!/bin/sh

[ -z "$GPG_SIGNING_KEY_FILE" ] || gpg -v --batch --import "$GPG_SIGNING_KEY_FILE"
[ -z "$GPG_SIGNING_KEY_ID" ] || git config --global user.signingkey "$GPG_SIGNING_KEY_ID"
[ -n "$GIT_USER_NAME" ] || git config --global user.name "$GIT_USER_NAME"
[ -n "$GIT_USER_EMAIL" ] || git config --global user.email "$GIT_USER_EMAIL"
[ -n "$DISCORD_TOKEN_FILE" ] || DISCORD_TOKEN="$(cat "$DISCORD_TOKEN_FILE")"

export DISCORD_TOKEN

trap 'gpgconf --kill gpg-agent' EXIT
"$@"
