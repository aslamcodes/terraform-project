data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


resource "aws_key_pair" "aslam_key" {
  public_key = file("~/.ssh/id_rsa.pub")
  key_name   = "aslam_key_2"
}

resource "aws_instance" "instance" {
  ami                    = data.aws_ami.amazon_linux.id
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.aslam_key.key_name
  subnet_id              = var.subnet_id
  iam_instance_profile   = var.instance_profile_name
  monitoring             = true
  ebs_optimized          = true

  root_block_device {
    encrypted = true
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apache2 php libapache2-mod-php",
      "sudo apt-get install php-mysqli",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2"
    ]
  }

  provisioner "file" {
    content     = <<EOT
    <?php
    $dbname = 'mydb';
    $dbuser = 'foo';
    $dbpass = 'foobarbaz';
    $dbhost = preg_replace('/:\d+$/', '', "${var.rds_endpoint}");

    // Connect to the database using mysqli
    $connect = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname);

    // Check connection
    if (!$connect) {
        die("Connection failed: " . mysqli_connect_error());
    }

    $test_query = "SHOW TABLES FROM $dbname";
    $result = mysqli_query($connect, $test_query);

    if (!$result) {
        die("Error running query: " . mysqli_error($connect));
    }

    $tblCnt = mysqli_num_rows($result);

    if ($tblCnt == 0) {
        echo "There are no tables<br />\n";
    } else {
        echo "There are $tblCnt tables<br />\n";
    }

    // Close the connection
    mysqli_close($connect);
    ?>
      EOT
    destination = "/tmp/mysql-connection.php"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/mysql-connection.php /var/www/html/mysql-connection.php",
      "sudo chown www-data:www-data /var/www/html/mysql-connection.php",
      "sudo systemctl restart apache2"
    ]
  }

  tags = {
    Name = "aslam-instance ${count.index}"
  }
}
