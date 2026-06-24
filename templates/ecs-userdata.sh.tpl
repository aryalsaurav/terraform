#!/bin/bash

dnf update -y
dnf install docker -y

systemctl enable --now docker

dnf install ecs-init

echo "ECS_CLUSTER=$cluster_name" >> /etc/ecs/ecs.config

systemctl enable --now --no-block esc.service
