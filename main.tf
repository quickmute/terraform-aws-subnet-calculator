variable "cidr" {
  type        = string
  description = "CIDR"
  default     = "10.10.0.0/24"
}

locals {
  ## Split the Host and Netmask
  cidr_array_orig = split("/", var.cidr)
  ## Convert the Host string into array
  cidr_array = flatten([split(".", local.cidr_array_orig[0]), split(".", local.cidr_array_orig[1])])
}

## Convert the first Octet 
module "first" {
  source        = "./bin_converter"
  decimal_value = local.cidr_array[0]
}

## Convert the second Octet 
module "second" {
  source        = "./bin_converter"
  decimal_value = local.cidr_array[1]
}

## Convert the third Octet 
module "third" {
  source        = "./bin_converter"
  decimal_value = local.cidr_array[2]
}

## Convert the fourth Octet 
module "fourth" {
  source        = "./bin_converter"
  decimal_value = local.cidr_array[3]
}

## Convert the mask
module "mask" {
  source        = "./bin_converter"
  decimal_value = local.cidr_array[4]
}

locals {
  ## This is the network mask as passed in
  netmask_decimal = local.cidr_array[4]
  ## This is the inverse of the network mask, or the part isn't meant to be masked
  netmask_decimal_inverse = 32 - local.netmask_decimal
  ## This is the raw host ip in binary, no decimal delimiter here
  host_binary_raw = join("", [module.first.binary, module.second.binary, module.third.binary, module.fourth.binary])
  ## This is the actual host ip with the mask applied, or starting point
  host_binary_raw_with_mask = join("", [
    substr(local.host_binary_raw, 0, local.netmask_decimal),
    strrev(replace(substr(strrev(local.host_binary_raw), 0, local.netmask_decimal_inverse), 1, 0))]
  )
  ## This is the boardcast address of the cidr range, or ending point
  bcast_binary_raw_with_mask = join("", [
    substr(local.host_binary_raw, 0, local.netmask_decimal),
    strrev(replace(substr(strrev(local.host_binary_raw), 0, local.netmask_decimal_inverse), 0, 1))]
  )

  ## Display friendly binary host, after the masking
  host_binary_with_mask = join(".", [
    substr(local.host_binary_raw_with_mask, 0, 8),
    substr(local.host_binary_raw_with_mask, 8, 8),
    substr(local.host_binary_raw_with_mask, 16, 8),
    substr(local.host_binary_raw_with_mask, 24, 8)]
  )
  ## display friendly binary broadcast, after the masking
  bcast_binary_with_mask = join(".", [
    substr(local.bcast_binary_raw_with_mask, 0, 8),
    substr(local.bcast_binary_raw_with_mask, 8, 8),
    substr(local.bcast_binary_raw_with_mask, 16, 8),
    substr(local.bcast_binary_raw_with_mask, 24, 8)]
  )
  ## display friendly decimal host, after the masking
  host_decimal_with_mask = join(".", [
    parseint(substr(local.host_binary_raw_with_mask, 0, 8), 2),
    parseint(substr(local.host_binary_raw_with_mask, 8, 8), 2),
    parseint(substr(local.host_binary_raw_with_mask, 16, 8), 2),
    parseint(substr(local.host_binary_raw_with_mask, 24, 8), 2)]
  )
  ## display friendly decimal boardcast address, after the masking
  bcast_decimal_with_mask = join(".", [
    parseint(substr(local.bcast_binary_raw_with_mask, 0, 8), 2),
    parseint(substr(local.bcast_binary_raw_with_mask, 8, 8), 2),
    parseint(substr(local.bcast_binary_raw_with_mask, 16, 8), 2),
    parseint(substr(local.bcast_binary_raw_with_mask, 24, 8), 2)]
  )

  host_long_decimal  = parseint(local.host_binary_raw_with_mask, 2)
  bcast_long_decimal = parseint(local.bcast_binary_raw_with_mask, 2)
  netmask_binary     = module.mask.binary
}

output "result" {
  value = {
    host_binary         = local.host_binary_with_mask
    bcast_binary        = local.bcast_binary_with_mask
    host_long_decimal   = local.host_long_decimal
    bcast_long_decimal  = local.bcast_long_decimal
    host_decimal        = local.host_decimal_with_mask
    bcast_decimal       = local.bcast_decimal_with_mask
    available_addresses = local.bcast_long_decimal - local.host_long_decimal
  }
}
