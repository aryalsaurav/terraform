[
    {
        "name": "server",
        "image": "${image_url}",
        "cpu": 0,
        "portMappings": [
            {
                "containerPort": 8000,
                "hostPort": 8000,
                "protocol": "tcp",
                "name": "server-8000-tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "command": [
            "gunicorn",
            "config.wsgi:application",
            "--bind",
            "0.0.0.0:8000"
        ],
        "environment": [],
        "environmentFiles": [
            {
                "value": "${env_file_arn}",
                "type": "s3"
            }
        ],
        "secrets": [
            {
                "name": "POSTGRES_PASSWORD",
                "valueFrom": "${db_secret_arn}:password::"
            }
        ],
        "mountPoints": [],
        "volumesFrom": [],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group}",
                "awslogs-create-group": "true",
                "awslogs-region": "${aws_region}",
                "awslogs-stream-prefix": "server"
            }
        },
        "systemControls": []
    }
]