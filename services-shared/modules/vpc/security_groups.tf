data "aws_security_group" "default" {
  vpc_id = aws_vpc.main.id
  name = "default"
}

resource "aws_security_group" "http" {
  name = "allow web"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80 
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# should not be used for production
# resource "aws_security_group" "ssh" {
#   name = "allow ssh"
#   vpc_id = aws_vpc.main.id
#   ingress {
#     from_port = 22
#     to_port = 22
#     cidr_blocks = ["0.0.0.0/0"]
#     protocol = "tcp"
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }