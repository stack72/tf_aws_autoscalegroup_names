## tf_aws_autoscale_groups

Terraform Module that reads a set of accounts from ~/.aws/credentials and queries each region to find the autoscale groups configured in that region

Needs the aws cli installed to shell out to.

To build the variables using the default AWS account run the command:

```
make all
```

To build the variables for a named AWS account, run the command:

```
make account=NAMEDACCOUNT all
```

### Inputs

* region - E.g. eu-west-1

### Outputs

* asg_names - a comma separated list of Autoscale Groups for a specific region and a specific account

### Example Usage

```
module "autoscalegroups" {
  source = "github.com/stack72/tf_aws_autoscalegroup_names"
  region = "eu-west-1"
}

resource "aws_autoscaling_notification" "slack_notifications" {
  group_names = [
    "${split(",", module.autoscalegroups.asg_names)}",
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH"
  ]
}
```
