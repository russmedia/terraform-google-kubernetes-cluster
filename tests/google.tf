terraform {
  backend "gcs" {
    bucket = "russmedia-automated-tests-tfstate"
    prefix = "terraform/tests"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  version = "~> 2.16"
}

provider "google-beta" {
  project = var.project
  region  = var.region
  version = "~> 3.78"
}

