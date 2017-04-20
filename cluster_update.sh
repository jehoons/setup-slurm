# distribute slurm.conf
pdsh -w ^nodes -R ssh "scp tesla0:slurm_setup/slurm.conf . && sudo cp slurm.conf /usr/local/etc"
pdsh -w ^nodes -R ssh "sudo /usr/local/sbin/slurmd -c"

sudo killall slurmctld
sudo /usr/local/sbin/slurmctld -c
