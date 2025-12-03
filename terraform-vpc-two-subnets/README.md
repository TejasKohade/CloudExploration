# terraform-vpc-two-subnets

Simple Terraform project that provisions:
- 1 VPC
- 1 public subnet (with IGW & public route)
- 1 private subnet
- 2 EC2 instances in public subnet (public IPs)
- 2 EC2 instances in private subnet (no public IPs)

Environment: `envs/dev`. Use the provided files to run Terraform.

**Warning:** This creates AWS resources and may incur costs. Run `terraform destroy` when done.
