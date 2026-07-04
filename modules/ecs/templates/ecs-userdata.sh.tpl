#!/bin/bash

exec > >(tee /var/log/user-data.log)
exec 2>&1

dnf install docker -y
systemctl enable --now docker


dnf install amazon-ssm-agent -y
systemctl enable --now amazon-ssm-agent

mkdir -p /etc/ecs
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config

dnf install ecs-init -y
systemctl enable --now --no-block ecs