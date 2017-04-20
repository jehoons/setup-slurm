sudo rm -f /usr/local/etc/slurm.conf
sudo cp slurm.conf /usr/local/etc
sudo killall slurmctld slurmd munged
sleep 1
sudo slurmctld
sleep 1
sudo slurmd
sleep 1 
sudo munged
sleep 1
sbatch hello.sh 

