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
                "awslogs-region": "${aws_region}",
                "awslogs-stream-prefix": "server"
            }
        },
        "healthCheck": {
            "command": [
                "CMD-SHELL",
                "curl -f http://localhost:8000/health || exit 1"
            ],
            "interval": 30,
            "timeout": 5,
            "retries": 3,
            "startPeriod": 60
        },
        "systemControls": []
    }
]