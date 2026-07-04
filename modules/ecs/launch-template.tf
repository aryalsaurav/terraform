data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix = "${var.prefix}-ecs-"

  image_id = data.aws_ami.amazon_linux.id

  instance_type = var.ecs_instance_type

  vpc_security_group_ids = [var.instance_sg_id]

  iam_instance_profile {
    arn = var.iam_instance_profile_arn
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
      var.tags,
      {
        Name = "${var.prefix}-ecs-instance"
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
    var.tags,
    {
      Name = "${var.prefix}-ecs-instance"
    }
  )
}