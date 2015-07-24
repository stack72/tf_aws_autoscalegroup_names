variable "region" {}

output "autoscalegroup_names" {
    value = "${lookup(var.autoscalegroup_names, var.region)}"
}
