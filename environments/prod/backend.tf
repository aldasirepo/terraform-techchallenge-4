terraform {
  backend "s3" {
    bucket = "techchallenge4-togglemaster-state"
    key    = "techchallenge4/prod/terraform.tfstate"
    region = "us-east-1"
  }
}
