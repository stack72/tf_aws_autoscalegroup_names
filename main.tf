variable "region" {}

output "asg_names" {
    value = "${lookup(var.autoscalegroup_names, var.region)}"
}
