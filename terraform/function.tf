# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
    type        = "zip"
    source_dir  = "../src"
    output_path = "./tmp/function.zip"
}

resource "google_storage_bucket" "function_bucket" {
    name     = "${var.project_id}-hola-mundo-gcf-bucket"
    location = var.region
}

resource "google_storage_bucket_object" "object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "function-source.zip" # Add path to the zipped function source code
}

resource "google_cloudfunctions_function" "function" {
    name                  = "hola-mundo-gcf"  
     description = "a new function"

     build_config {  
        runtime               = var.python
        entry_point           = "Hola_Mundo"
        source  {
            storage_source  {
                bucket = google_storage_bucket.function_bucket.name
                object = google_storage_bucket_object.object.name
            }
        }
    }
}
