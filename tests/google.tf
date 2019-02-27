terraform {
  backend "gcs" {
    bucket = "russmedia-automated-tests-tfstate"
    prefix = "terraform/tests"
  }
}
