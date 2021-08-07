locals {
  domains = toset([for domain in setunion(
    toset([for s in var.static_sites : s.hostname]),
  ) : regex("[^.]+.[^.]+$", domain)])

  # Maps all full domain sites like: 
  #   api.example.com
  #   my.www.example.com
  #  To:
  #   example.com
  static_site_domains_to_root_domain = {
    for site in var.static_sites : site.hostname => regex("[^.]+.[^.]+$", site.hostname)
  }

  static_sites = {
    for site in var.static_sites : site.hostname => site
  }
}
