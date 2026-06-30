[
    {
        "name": "beat",
        "image": "${image_url}",
        "cpu": 0,
        "essential": true,
        "command": [
            "celery",
            "-A",
            "config.celery",
            "beat",
            "--loglevel=info"
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
        "systemControls": []
    }
]