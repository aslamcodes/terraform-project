provider "aws" {
  alias  = "east"
  region = "us-east-1"
  default_tags {
    tags = {
      owner   = "Mohamed Aslam"
      project = "Cross region vpc peering project"
    }
  }
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
  default_tags {
    tags = {
      owner   = "Mohamed Aslam"
      project = "Cross region vpc peering project"
    }
  }
}
