resource "google_compute_commitment" "commitment_1yr" {
  name    = "gce-commitment-1-year"
  region  = "us-central1"
  plan    = "TWELVE_MONTHS"
  type    = "GENERAL_PURPOSE"

  resources {
    type = "VCPU"
    amount = "4"
  }

  resources {
    type = "MEMORY"
    amount = "16384"
  }
}

resource "google_compute_commitment" "commitment_3yr" {
  name    = "gce-commitment-3-years"
  region  = "us-central1"
  plan    = "THIRTY_SIX_MONTHS"
  type    = "GENERAL_PURPOSE"

  resources {
    type = "VCPU"
    amount = "8"
  }

  resources {
    type = "MEMORY"
    amount = "32768"
  }
}