variable "region" {}

output "asg_names" {
    value = "${join(",", lookup(var.autoscalegroup_names, var.region))}"
}
