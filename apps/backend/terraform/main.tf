resource "cloudflare_record" "google_verification" {
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "@"
  value   = "google-site-verification=${var.domain_verification_token}"
  type    = "TXT"
  ttl     = "Auto"
}
# Create Google Cloud Storage Bucket
resource "google_storage_bucket" "rosterroyale_frontend_bucket" {
  name     = "rosterroyale.com"
  location = var.region
  website {
    main_page_suffix = "index.html"
  }

  # Make the bucket public
  uniform_bucket_level_access = true
  force_destroy = true
  depends_on = [cloudflare_record.google_verification]
}

# Configure bucket access to be public
resource "google_storage_bucket_iam_member" "allUsers" {
  bucket = google_storage_bucket.rosterroyale_frontend_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Cloudflare DNS record for your root domain
resource "cloudflare_record" "root_domain" {
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "@"
  value   = "c.storage.googleapis.com"  # Use this for the root domain
  type    = "CNAME"
  proxied = false
}

# Cloudflare DNS record for www subdomain
resource "cloudflare_record" "www_domain" {
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "www"
  value   = "c.storage.googleapis.com"  # Use this for the www subdomain
  type    = "CNAME"
  proxied = false
}