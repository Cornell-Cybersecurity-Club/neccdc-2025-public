resource "aws_ecrpublic_repository" "website" {
  repository_name = "placebo-pharma/website"

  catalog_data {
    about_text        = ""
    operating_systems = ["Linux"]
  }
}


resource "aws_ecrpublic_repository" "etcher" {
  repository_name = "placebo-pharma/etcher"

  catalog_data {
    about_text        = ""
    operating_systems = ["Linux"]
  }
}


resource "aws_ecrpublic_repository" "grapher_http" {
  repository_name = "placebo-pharma/grapher-http"

  catalog_data {
    about_text        = ""
    operating_systems = ["Linux"]
  }
}

resource "aws_ecrpublic_repository" "grapher_renderer" {
  repository_name = "placebo-pharma/grapher-renderer"

  catalog_data {
    about_text        = ""
    operating_systems = ["Linux"]
  }
}


resource "aws_ecrpublic_repository" "processor" {
  repository_name = "placebo-pharma/processor"

  catalog_data {
    about_text        = ""
    operating_systems = ["Linux"]
  }
}


resource "aws_ecrpublic_repository" "recorder" {
  repository_name = "placebo-pharma/recorder"

  catalog_data {
    about_text        = ""
    operating_systems = ["Linux"]
  }
}
