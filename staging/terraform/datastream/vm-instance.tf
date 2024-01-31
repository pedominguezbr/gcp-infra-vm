locals {
  ssh_keys = [
    {
      username   = "bruno"
      public_key = "~/.ssh/id_rsa.pub"
    },
  ]
}

resource "random_id" "id_name" {
  byte_length = 8
}

resource "google_compute_address" "static_ip" {
  provider     = google
  name         = "static-ip-vm"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_compute_instance" "vm_jmeter" {
  project      = var.gcloud_project_id
  name         = "${var.name_instance}-vm"
  machine_type = "n2-standard-4" #"e2-micro" "f1-micro" "n2-standard-4"
  zone         = var.gcloud_zone

  boot_disk {
    initialize_params {
      # image = "busybox"
      image = "debian-cloud/debian-11"
      size  = "30" #GB
    }
  }

  network_interface {
    network            = data.google_compute_network.vpc.self_link    #module.vpc-module.network_self_link  data.google_compute_network.default_network.self_link
    subnetwork_project = var.gcloud_project_id                        #var.subnetwork_project
    subnetwork         = "${var.gcloud_project_id}-vpc-subnet-jmeter" #"subnet-redis" #var.subnetwork

    # # Add for suppor IPV6 external
    # stack_type = "IPV4_IPV6"
    # ipv6_access_config {

    #   network_tier = "PREMIUM"
    #   ## To confirm the PTR records have been set, you can run the following command:
    #   ## Search for the reverse DNS record of an IP
    #   ## using Google's DNS servers:
    #   ## dig -x "$IP" @8.8.8.8
    #   public_ptr_domain_name = "testing-jmeter-vm.pdominguezb-lab.xyz."
    # }

    access_config {
      nat_ip                 = google_compute_address.static_ip.address
      network_tier           = "PREMIUM"
      # public_ptr_domain_name = "testing-jmeter-vm.pdominguezb-lab.xyz."
    }
  }

  metadata = {
    ssh-keys = join("\n", [for key in local.ssh_keys : "${key.username}:${file(key.public_key)}"])
  }

  tags              = ["allow-web", "allow-ssh", "allow-icmp"]
  labels            = {}
  resource_policies = []
  # metadata = {
  #   gce-container-declaration = module.gce-advanced-container.metadata_value
  # }

  # labels = {
  #   container-vm = module.gce-advanced-container.vm_container_label
  # }

  service_account {
    email = var.client_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  # provisioner "file" {
  #   source      = var.path_local_file_sa_pk
  #   destination = "/home/bruno/iam-acount-cloudsqlproxy1.json"

  #   connection {
  #     host        = google_compute_instance.vm_jmeter.network_interface[0].access_config[0].nat_ip
  #     type        = "ssh"
  #     user        = "bruno"
  #     private_key = file("~/.ssh/id_rsa")
  #     agent       = "false"
  #   }
  # }
  provisioner "remote-exec" {
    connection {
      host        = google_compute_instance.vm_jmeter.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      port        = 22
      user        = var.vm_username
      agent       = "false"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt -y install wget unzip curl git cmake gcc dnsutils",
      "sudo apt -y install openjdk-11-jre-headless",
      "sudo apt -y install openjdk-11-jdk-headless",
      "wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.5.zip -O /home/${var.vm_username}/apache-jmeter-5.5.zip",
      "unzip /home/${var.vm_username}/apache-jmeter-5.5.zip",
      "mv /home/${var.vm_username}/apache-jmeter-5.5 jmeter",
      "sudo mv /home/${var.vm_username}/jmeter /opt",
      "echo 'export PATH=\"$PATH:/opt/jmeter/bin\"' >> ~/.bashrc",
    ]
  }

  provisioner "remote-exec" {
    connection {
      host        = google_compute_instance.vm_jmeter.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      port        = 22
      user        = var.vm_username
      agent       = "false"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt -y install curl apt-transport-https ca-certificates gnupg ",
      "curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "echo \"deb https://packages.cloud.google.com/apt cloud-sdk main\" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list ",
      "sudo apt update -y",
      "sudo apt-get install kubectl -y",
      "sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y",
    ]
  }

  ##Install docker
  provisioner "remote-exec" {
    connection {
      host        = google_compute_instance.vm_jmeter.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      port        = 22
      user        = var.vm_username
      agent       = "false"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt -y install lsb-release jq ",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update -y",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io -y",
      "sudo usermod -aG docker ${var.vm_username}"
    ]
  }

  depends_on = [
    google_compute_subnetwork.vpc_subnet_jmeter,
  ]
}

########script jmeter
# jmeter -n -t /home/bruno/test-staging/miapp-staging-login.jmx -l /home/bruno/test-staging/Result-1.csv
##Configurar gcloud
#sudo gcloud init --console-only
# ##Install docker-compose debian 11
# sudo apt update
# sudo curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# docker-compose --version
