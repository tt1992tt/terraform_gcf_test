# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
    type        = "zip"
    source_dir  = "../src"
    output_path = "./tmp/function.zip"
}

resource "google_storage_bucket_object" "zip" {
    source       = data.archive_file.source.output_path
    content_type = "application/zip"

    # Append to the MD5 checksum of the files's content
    # to force the zip to be updated as soon as a change occurs
    name         = "src-${data.archive_file.source.output_md5}.zip"
    bucket       = google_storage_bucket.function_bucket.name

    # Dependencies are automatically inferred so these lines can be deleted
    depends_on   = [
        google_storage_bucket.function_bucket,  # declared in `storage.tf`
        data.archive_file.source
    ]
}

resource "google_cloudfunctions_function" "function" {
    name        = "hola-mundo-gcf"  
    description = "a new function"
    runtime     = var.python
    entry_point = "Hola_Mundo"
    
    depends_on = [
        google_storage_bucket.function_bucket,
        google_storage_bucket_object.zip
    ]
}
