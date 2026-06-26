[
    {
        "name": "server-migration",
        "image": "${image_url}",
        "cpu": 0,
        "portMappings": [],
        "essential": true,
        "command": [
            "sh",
            "-c",
            "python manage.py migrate --noinput && python manage.py collectstatic --noinput"
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
                "awslogs-stream-prefix": "migration"
            }
        },
        "systemControls": []
    }
]