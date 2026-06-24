data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix = "${local.prefix}-ecs-"

  image_id = data.aws_ami.amazon_linux.id

  instance_type = var.ecs_instance_type

  vpc_security_group_ids = [aws_security_group.ecs_instance.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance.arn
  }

  user_data = base64encode(
    templatefile(
      "${path.module}/templates/ecs-userdata.sh.tpl",
      {
        cluster_name = aws_ecs_cluster.main.name
      }
    )
  )
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.prefix}-ecs-instance"
      }
    )
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-ecs-instance"
    }
  )
}