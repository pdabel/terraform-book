module "db_server" {
  source                  = "../../../modules/data-stores/mysql"
  
  cluster_name            = "db-stage"
  db_remote_state_bucket  = "${var.db_remote_state_bucket}"
  db_remote_state_key     = "${var.db_remote_state_key}"
  db_password             = "${var.db_password}"
}
