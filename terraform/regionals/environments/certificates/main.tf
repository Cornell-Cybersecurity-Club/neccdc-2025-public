locals {
  # Starting index 1 = team 0
  teams = 11
}

module "certs" {
  source = "../../modules/certificates"

  for_each = { for i in range(local.teams) : i => tostring(i) }

  domain_name = "placebo-pharma.com"
  output_dir  = "../../../../documentation/blue_team/regionals/"
  team_number = each.key
}
