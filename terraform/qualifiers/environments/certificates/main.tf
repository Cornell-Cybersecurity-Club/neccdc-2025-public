locals {
  # Starting index 1 = team 0
  teams = 21
}

module "certificates" {
  source = "../../modules/certificates"

  for_each = { for i in range(local.teams) : i => tostring(i) }

  domain_name = "placebo-pharma.com"
  output_dir  = "../../../../documentation/blue_team/qualifiers/"
  team_number = each.key
}
