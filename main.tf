module "vpc_1" {
  source                = "git::ssh://git@gitlab.presidio.com/mohammedaslamm/tf-project.git//modules/vpc?ref=9162f638f9770a3776abed4eaa431e6fd4e96820"
  azs                   = ["us-east-1a", "us-east-1b"]
  cidr_block            = "10.0.0.0/16"
  private_subnets_CIDRs = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnet_CIDRs   = ["10.0.2.0/24", "10.0.3.0/24"]
  subnet_count          = 2
  providers = {
    aws = aws.east
  }
}

module "vpc_2" {


  source = "git::ssh://git@gitlab.presidio.com/mohammedaslamm/tf-project.git//modules/vpc?ref=9162f638f9770a3776abed4eaa431e6fd4e96820"

  azs                   = ["us-west-2a", "us-west-2b"]
  cidr_block            = "10.1.0.0/16"
  private_subnets_CIDRs = ["10.1.0.0/24", "10.1.1.0/24"]
  public_subnet_CIDRs   = ["10.1.2.0/24", "10.1.3.0/24"]
  subnet_count          = 2
  providers = {
    aws = aws.west
  }
}

module "vpc_peering" {
  depends_on = [module.vpc_1, module.vpc_2]
  source     = "git::ssh://git@gitlab.presidio.com/mohammedaslamm/tf-project.git//modules/vpc_peering_w_routes?ref=9162f638f9770a3776abed4eaa431e6fd4e96820"

  main_rtb_id    = module.vpc_1.public_rtb_id
  peering_rtb_id = module.vpc_2.public_rtb_id

  main_vpc_cidr = module.vpc_1.cidr
  peer_vpc_cidr = module.vpc_2.cidr

  vpc_id      = module.vpc_1.vpc_id
  peer_vpc_id = module.vpc_2.vpc_id

  peer_region = "us-west-2"

  providers = {
    aws.east = aws.east
    aws.west = aws.west
  }
}



module "iam_role" {
  source = "git::ssh://git@gitlab.presidio.com/mohammedaslamm/tf-project.git//modules/iam_role?ref=9162f638f9770a3776abed4eaa431e6fd4e96820"
}

module "rds" {
  source        = "git::ssh://git@gitlab.presidio.com/mohammedaslamm/tf-project.git//modules/rds?ref=9162f638f9770a3776abed4eaa431e6fd4e96820"
  db_subnets    = module.vpc_1.public_subnet_ids
  vpc_id        = module.vpc_1.vpc_id
  ingress_cidrs = [module.vpc_1.cidr, module.vpc_2.cidr]
  providers = {
    aws = aws.east
  }
}

module "ec2-1" {
  source                = "git::ssh://git@gitlab.presidio.com/mohammedaslamm/tf-project.git//modules/ec2?ref=9162f638f9770a3776abed4eaa431e6fd4e96820"
  instance_type         = "t2.medium"
  rds_endpoint          = module.rds.rds_endpoint
  instance_count        = 1
  subnet_id             = module.vpc_1.public_subnet_ids[0]
  vpc_id                = module.vpc_1.vpc_id
  instance_profile_name = module.iam_role.instance_profile
  providers = {
    aws = aws.east
  }
}

module "ec2-2" {
  source                = "git::ssh://git@gitlab.presidio.com/mohammedaslamm/tf-project.git//modules/ec2?ref=9162f638f9770a3776abed4eaa431e6fd4e96820"
  instance_type         = "t2.medium"
  rds_endpoint          = module.rds.rds_endpoint
  instance_count        = 1
  subnet_id             = module.vpc_2.public_subnet_ids[0]
  vpc_id                = module.vpc_2.vpc_id
  instance_profile_name = module.iam_role.instance_profile
  providers = {
    aws = aws.west
  }
}




output "vpc_id" {
  value = "${module.vpc_1.vpc_id} ${module.vpc_2.vpc_id}"
}

output "peer_id" {
  value = module.vpc_peering.peering_id
}


output "ip1" {
  value = module.ec2-1.apache_server_ip
}

output "ip2" {
  value = module.ec2-2.apache_server_ip
}


output "endpoint" {
  value = module.rds.rds_endpoint
}
