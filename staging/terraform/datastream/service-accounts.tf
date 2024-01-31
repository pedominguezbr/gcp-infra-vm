# resource "google_service_account" "cloudsqlproxy" {
#   account_id   = "miapp-staging-cloudsqlproxy"
#   display_name = "miapp staging cloudsqlproxy"
# }

# resource "google_project_iam_binding" "cloudsql_editor" {
#   project = var.gcloud_project_id
#   role    = "roles/cloudsql.editor"
#   members = [
#     "serviceAccount:${google_service_account.cloudsqlproxy.email}",
#   ]
# }

# resource "google_service_account_key" "service_account_key" {
#   service_account_id = google_service_account.cloudsqlproxy.id
#   public_key_type    = "TYPE_X509_PEM_FILE"
# }

# resource "local_file" "service_account" {
#   content  = base64decode(google_service_account_key.service_account_key.private_key)
#   filename = var.path_local_file_sa_pk
# }
