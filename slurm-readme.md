### SLURM install 

Step 1. Be using Ubuntu 

Step 2. Install:

http://www.schedmd.com/#repos
```
./configure
make 
make install 
```

Step 3. Create key for MUNGE authentication: /usr/sbin/create-munge-key 

```bash
git clone git@github.com:dun/munge.git
```
create-munge-key

Step 4a. Make config file: https://computing.llnl.gov/linux/slurm/configurator.html 

Step 4b. Put config file in: /etc/slurm-llnl/slurm.conf 

Step 5. Start master: # slurmctld 

Step 6. Start node: # slurmd 

sinfo 를 이용해서 상태확인하기 .

Step 7. Test that fool: $ srun -N1 /bin/hostname  

### Job submitting 
https://ubccr.freshdesk.com/support/solutions/articles/5000688140-submitting-a-slurm-job-script
https://www.lrz.de/services/compute/linux-cluster/batch_parallel/example_jobs/

### Trouble shooting 

sinfo에서 drain으로 나오는 경우

해결방법 http://stackoverflow.com/questions/29535118/how-to-undrain-slurm-nodes-in-drain-state


### 노드설치하기 

참고: 

https://github.com/grondo/pdsh



Ref. 
* http://sphaleron.blogspot.kr/2011/08/really-super-quick-start-guide-to.html

