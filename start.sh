#!/bin/bash

REPO=$REPO
ACCESS_TOKEN=$TOKEN

# Generates random name for runner
chars='abcdefghijklmnopqrstuvwxyz1234567890'
n=10

RUNNER_NAME=
for ((i = 0; i < n; ++i)); do
    RUNNER_NAME+=${chars:RANDOM%${#chars}:1}
done

REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/repos/${REPO}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/${REPO} --token ${REG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
	echo "Removing runner..."
	./config.sh remove --local --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
