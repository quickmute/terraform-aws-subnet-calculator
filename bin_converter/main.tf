##
## This tiny module will convert a decimal to binary
## Only supports up to 7 binary spaces
## Uses long division method of converting from decimal to binary
##
variable "decimal_value" {
  type        = number
  default     = 64
  description = "Integer between 0 and 255"
  validation {
    condition     = var.decimal_value >= 0 && var.decimal_value < 256
    error_message = "Outside of valid range (0-255)."
  }
}

locals {
  ## This is the starting value
  start = var.decimal_value

  ## Long Division
  ## Divide it by 2 then pass on the Quotient to the next step
  ## The remainder is the binary value

  ## First Long Division
  ## 1st position, 2^0
  value1 = local.start % 2
  next1  = floor(local.start / 2)
  ## 2nd position, 2^1
  value2 = local.next1 % 2
  next2  = floor(local.next1 / 2)
  ## 3rd position, 2^2
  value3 = local.next2 % 2
  next3  = floor(local.next2 / 2)
  ## 4th position, 2^3
  value4 = local.next3 % 2
  next4  = floor(local.next3 / 2)
  ## 5th position, 2^4
  value5 = local.next4 % 2
  next5  = floor(local.next4 / 2)
  ## 6th position, 2^5
  value6 = local.next5 % 2
  next6  = floor(local.next5 / 2)
  ## 7th position, 2^6
  value7 = local.next6 % 2
  next7  = floor(local.next6 / 2)
  ## 8th position, 2^7
  value8 = local.next7 % 2
  next8  = floor(local.next7 / 2)

  ## Put it all together
  bin_result = strrev(join("", [
    local.value1,
    local.value2,
    local.value3,
    local.value4,
    local.value5,
    local.value6,
    local.value7,
    local.value8]
    )
  )
}

output "binary" {
  description = "Binary Result"
  value       = local.bin_result
}
