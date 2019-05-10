#!/bin/bash

project_path=`realpath "$1"`
project=`basename $project_path`
user=`whoami`
docker run --name dev-docker --privileged -p22 --user $user \
    --mount type=bind,source=${project_path},target=/home/$user/${project} \
    -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /home/$user/.kube:/home/$user/.kube \
    -v /home/$user/.minikube:/home/$user/.minikube \
    -it dev:1.0.0
