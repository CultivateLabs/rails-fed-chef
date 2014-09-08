name "nfs"
description "Role applied to the system that should be an NFS server."
override_attributes(
  "nfs" => {
    "packages" => [ "portmap", "nfs-common", "nfs-kernel-server" ]
  }
)
run_list [ "nfs::server", "recipe[nfs-setup]" ]