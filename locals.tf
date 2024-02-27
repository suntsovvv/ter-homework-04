locals{
    vms_metadata = {
      serial-port-enable = 1
      ssh-key  = "user:${file("~/.ssh/id_ed25519.pub")} " 
    }
}

