data "oci_containerengine_cluster_kube_config" "cluster_kube_config" {
  cluster_id    = "${oci_containerengine_cluster.cluster.id}"
  expiration    = 2592000
  token_version = "1.0.0"
}

resource "local_file" "cluster_kube_config_file" {
  content  = "${data.oci_containerengine_cluster_kube_config.cluster_kube_config.content}"
  filename = "config"
}

resource "oci_containerengine_cluster" "cluster" {
  compartment_id     = "${var.compartment_ocid}"
  kubernetes_version = "${data.oci_containerengine_cluster_option.cluster_option.kubernetes_versions.1}"
  name               = "${var.oke["name"]}"
  vcn_id             = "${oci_core_virtual_network.virtual_network.id}"

  options {
    service_lb_subnet_ids = ["${oci_core_subnet.lbsubnet0.id}", "${oci_core_subnet.lbsubnet1.id}"]
  }
}

resource "oci_containerengine_node_pool" "node_pool" {
  cluster_id          = "${oci_containerengine_cluster.cluster.id}"
  compartment_id      = "${var.compartment_ocid}"
  kubernetes_version  = "${data.oci_containerengine_node_pool_option.node_pool_option.kubernetes_versions.0}"
  name                = "${var.oke["name"]}"
  node_image_name     = "Oracle-Linux-7.5"
  node_shape          = "${var.oke["shape"]}"
  subnet_ids          = ["${oci_core_subnet.subnet0.id}", "${oci_core_subnet.subnet1.id}", "${oci_core_subnet.subnet2.id}"]
  quantity_per_subnet = "${var.oke["nodes_per_subnet"]}"
  ssh_public_key      = "${var.ssh_public_key}"
}

output "cluster" {
  value = {
    id                 = "${oci_containerengine_cluster.cluster.id}"
    kubernetes_version = "${oci_containerengine_cluster.cluster.kubernetes_version}"
    name               = "${oci_containerengine_cluster.cluster.name}"
  }
}

output "node_pool" {
  value = {
    id                 = "${oci_containerengine_node_pool.node_pool.id}"
    kubernetes_version = "${oci_containerengine_node_pool.node_pool.kubernetes_version}"
    name               = "${oci_containerengine_node_pool.node_pool.name}"
    subnet_ids         = "${oci_containerengine_node_pool.node_pool.subnet_ids}"
  }
}