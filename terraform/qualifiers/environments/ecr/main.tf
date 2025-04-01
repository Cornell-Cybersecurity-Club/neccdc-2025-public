resource "aws_ecrpublic_repository" "etcher" {
  repository_name = "placebopharma/etcher"

  catalog_data {
    about_text        = "Pushes machine data into InfluxDB"
    operating_systems = ["Linux"]
  }
}


resource "aws_ecrpublic_repository" "grapher" {
  repository_name = "placebopharma/grapher"

  catalog_data {
    about_text        = "Graphs pretty pictures"
    operating_systems = ["Linux"]
  }
}


resource "aws_ecrpublic_repository" "recorder" {
  repository_name = "placebopharma/recorder"

  catalog_data {
    about_text        = "Records trial information for later analysis and auditing purposes"
    operating_systems = ["Linux"]
  }
}
