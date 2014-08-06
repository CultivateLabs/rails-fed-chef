name "nfs-client"
description "NFS client role that mounts the NFS share"
run_list [ "nfs", "recipe[nfs-setup::client]" ]