resource "aws_ecr_registry" "backend" {
    name    = "${var.project_name}-backend"
    image_tag_mutability = "IMMUTABLE"

    image_scanning_configuration {

        scan_on_push = true
    }
}

resource "aws_ecr_registry" "frontend" {
    name    = "${var.project_name}-frontend"
    image_tag_mutability = "IMMUTABLE"

    image_scanning_configuration {

        scan_on_push = true
    }
}