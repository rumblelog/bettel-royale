#!/bin/sh
set -e
set -u

OLDPWD=$(pwd)

[ -z "$GPG_SIGNING_KEY_FILE" ] || gpg -v --batch --import "$GPG_SIGNING_KEY_FILE"
[ -z "$GPG_SIGNING_KEY_ID" ] || (git config --global user.signingkey "$GPG_SIGNING_KEY_ID" && git config --global commit.gpgsign "true")
[ -z "$GIT_USER_NAME" ] || git config --global user.name "$GIT_USER_NAME"
[ -z "$GIT_USER_EMAIL" ] || git config --global user.email "$GIT_USER_EMAIL"
[ -z "$DISCORD_TOKEN_FILE" ] || DISCORD_TOKEN="$(cat "$DISCORD_TOKEN_FILE")"
if [ -n "$SSH_KNOWN_HOSTS_FILE" ]; then
    mkdir -p ~/.ssh
    cat "$SSH_KNOWN_HOSTS_FILE" >~/.ssh/known_hosts
fi
if [ -n "$SSH_KEY_FILE" ]; then
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY_FILE"
fi

export DISCORD_TOKEN
trap 'gpgconf --kill gpg-agent && rm -f ~/.gnupg/public-keys.d/pubring.db.lock' EXIT

: "${EXT_CLONE_DIR:=/var/tmp/repo}"
: "${EXT_CLONE_URL:=https://github.com/icedream/hololive-bettel-royale-data-processing.git}"
if [ "${EXT_CLONE:-0}" -ne 0 ]; then
    if [ ! -d "$EXT_CLONE_DIR/.git" ]; then
        git init "$EXT_CLONE_DIR"
        cd "$EXT_CLONE_DIR"
        git remote add origin "$EXT_CLONE_URL"
        git fetch origin
        git checkout main
    else
        cd "$EXT_CLONE_DIR"
        git reset --hard
        git clean -ffdx
        git pull
    fi
    cp "$OLDPWD/process-discord-exports" .
fi

"$@"
