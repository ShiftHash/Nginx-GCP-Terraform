#----------------------------------------------------------
# Terraform with GCP - Google Cloud Platform
# Nginx Server on Ubuntu
#-----------------------------------------------------------
provider "google" {
  credentials = file("mygcp-nginx.json")
  project     = "<********************************>"
  region      = var.region
  zone        = var.zone
}

resource "google_compute_firewall" "default" {
  name    = "allow-http-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-http-ssh"]
}

resource "google_compute_instance" "my_web_server" {
  name         = "my-gcp-nginx-server"
  machine_type = "f1-micro"
  tags = ["allow-http-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"   // This Enable Private IP Address
    access_config {}      // This Enable Public IP Address
  }

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }

  provisioner "file" {
    # source file name on the local machine where you execute terraform plan and apply
    source      = "startupscript.sh"
    # destination is the file location on the newly created instance
    destination = "/tmp/startupscript.sh"
    connection {
      host        = google_compute_instance.my_web_server.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      # username of the instance would vary for each account refer the OS Login in GCP documentation
      user        = var.user
      timeout     = "500s"
      # private_key being used to connect to the VM. ( the public key was copied earlier using metadata )
      private_key = file(var.privatekeypath)
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = google_compute_instance.my_web_server.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      # username of the instance would vary for each account refer the OS Login in GCP documentation
      user        = var.user
      timeout     = "500s"
      # private_key being used to connect to the VM. ( the public key was copied earlier using metadata )
      private_key = file(var.privatekeypath)
    }

    # Commands to be executed as the instance gets ready.
    inline = [
      "chmod a+x /tmp/startupscript.sh",
      "sed -i -e 's/\r$//' /tmp/startupscript.sh",
      "sudo /tmp/startupscript.sh"
    ]
  }

}

output "ip" {
  value = "${google_compute_instance.my_web_server.network_interface.0.access_config.0.nat_ip}"
}

output "ssh_access_via_ip" {
  value = "ssh ${var.user}@${google_compute_instance.my_web_server.network_interface.0.access_config.0.nat_ip}"
}