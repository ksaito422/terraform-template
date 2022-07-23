module "route53_record_writer" {
  source = "../modules/route53_record"

  route53_zone_id = data.aws_route53_zone.main.zone_id
  route53_name    = local.domain_db_writer
  type            = "CNAME"
  records         = [module.rds.rds_cluster_writer_endpoint]
}

module "route53_record_reader" {
  source = "../modules/route53_record"

  route53_zone_id = data.aws_route53_zone.main.zone_id
  route53_name    = local.domain_db_reader
  type            = "CNAME"
  records         = [module.rds.rds_cluster_reader_endpoint]
}

