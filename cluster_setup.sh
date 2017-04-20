# # install munge :
# pdsh -w ^nodes -R ssh "sudo rm -f /usr/local/lib/libmunge* /usr/local/include/munge.h /usr/local/bin/*munge /usr/local/sbin/munged /usr/local/etc/munge/munge.key"
# pdsh -w ^nodes -R ssh "ls /usr/local/sbin/munged"


# pdsh -w ^nodes -R ssh "mkdir -p tmp" 
# pdsh -w ^nodes -R ssh "cd tmp && scp tesla0:slurm_setup/munge-0.5.11.tgz ."
# pdsh -w ^nodes -R ssh "cd tmp && tar xvfz munge-0.5.11.tgz" 
# pdsh -w ^nodes -R ssh "cd tmp/munge-0.5.11 && ./configure --enable-shared=no CFLAGS=-fPIC && make clean && make -j50 && sudo make install"


# # check 
# pdsh -w ^nodes -R ssh "ls /usr/local/sbin/munged"
# pdsh -w ^nodes -R ssh "ls /usr/local/lib/libmunge*"

mkdir -p tmp
cd tmp
scp pascal:git/codebase/slurm/munge.key .
sudo mkdir -p /usr/local/etc/munge
sudo mv munge.key /usr/local/etc/munge/munge.key
sudo chown root:root /usr/local/etc/munge/munge.key
sudo chmod 600 /usr/local/etc/munge/munge.key
cd .. 
rm -rf tmp

# # check the date:
# pdsh -w ^nodes -R ssh "ls -l /usr/local/sbin/slurmctld"

# distribute slurm.conf
# pdsh -w ^nodes -R ssh "scp tesla0:slurm_setup/slurm.conf . && sudo cp slurm.conf /usr/local/etc"

mkdir -p tmp
cd tmp
scp pascal:git/codebase/slurm/slurm.conf . 
sudo cp slurm.conf /usr/local/etc
cd ..
rm -rf tmp

# start slurm
# pdsh -w ^nodes -R ssh "sudo killall munged"
# pdsh -w ^nodes -R ssh "sudo /usr/local/sbin/munged"
# pdsh -w ^nodes -R ssh "sudo /usr/local/sbin/slurmd -c"
# sudo killall slurmctld
# sudo /usr/local/sbin/slurmctld -c

# check user 
# pdsh -w ^nodes -R ssh "id jhsong1"
# check passwd file. uid should be same, so you will need to check this...  
# pdsh -w ^nodes -R ssh "tail -n1 /etc/passwd" 

# add new user to linux system 
# pdsh -w ^nodes -R ssh "sudo adduser new_user -u "
# pdsh -w ^nodes -R ssh "echo sbl4365 | sudo passwd new_user --stdin"


