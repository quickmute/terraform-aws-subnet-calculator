# terraform-aws-subnet-calculator

This module takes Subnet in CIDR notation in Decimal such as `10.10.0.0/24` and returns Binary and Long Decimal notation. 
You can use the long decimal values to determine if you have an overlap with another subnet. 


Following values are returned:
- available_addresses
- host_binary
- host_decimal
- host_long_decimal
- bcast_binary
- bcast_decimal
- bcast_long_decimal

# How to run
Drop this module into a directory, then reference it in your module call
```
locals {
  cidrs = [
    "10.64.60.0/24",
    "10.69.19.0/24",
    "10.65.19.0/16",
  ]
  cidrs_map = {
    for item in local.cidrs :
    item => item
  }
}

module "converted" {
  source   = "./cidr_converter"
  for_each = local.cidrs_map
  cidr     = each.value
}

locals {
  cidr_bin = {
    for key, value in module.converted :
    key => value.result
  }
}

output "result" {
  value = local.cidr_bin
}

```
