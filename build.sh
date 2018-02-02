#!/bin/sh
echo "--- MAKE IMAGES"
docker pull alpine:3.7
docker build -t bug:workdir -f Dockerfile.workdir .
docker build -t bug:volume -f Dockerfile.volume .
echo

echo "--- INSTALL SSHFS PLUGIN"
docker plugin disable sshfs
docker plugin rm sshfs
docker plugin install vieux/sshfs --alias=sshfs --grant-all-permissions
echo

echo "--- CREATE VOLUME"
docker volume create -d sshfs:latest test \
                     -o sshcmd="storage@localhost:/home/storage/test" \
                     -o password=hello \
                     -o allow_other
docker volume ls | grep sshfs
echo

echo "--- RUN ALPINE"
docker run --rm \
           --mount type=volume,src=test,dst=/data,volume-driver=sshfs:latest \
           alpine:3.7 ls /data
echo

echo "--- RUN BUG:VOLUME"
docker run --rm \
           --mount type=volume,src=test,dst=/data,volume-driver=sshfs:latest \
           bug:volume ls /data
echo

echo "--- RUN BUG:WORKDIR"
docker run --rm \
           --mount type=volume,src=test,dst=/data,volume-driver=sshfs:latest \
           bug:workdir ls /data
echo

echo "--- REMOVE VOLUME"
docker volume rm test
