
output "db_endpoint" {
  value = aws_docdb_cluster._.endpoint
}

output "db_reader_endpoint" {
  value = aws_docdb_cluster._.reader_endpoint
}