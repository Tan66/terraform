module "vpc" {
  source = "../modules/vpc"
}

module "ec2" {
  depends_on = [
    module.vpc
  ]
  source                 = "../modules/ec2"
  subnet_id              = module.vpc.public_subnet_ids[1]
  vpc_security_group_ids = [module.vpc.ec2_security_group_id]
  user_data              = file("init.sh")
}