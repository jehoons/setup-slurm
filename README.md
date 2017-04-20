
시작에 앞서서 사용자 아이디를 생성하고, 다음과 같이 SU권한을 주도록 하자. 
```
sudo adduser <username> sudo
```

또한, 모든 컴퓨터들이 상호간에 ssh접속을 할수 있는지 확인하자. 서버는 셀프접속도 확인해야 한다.

Step 1. Install dependency

```
sudo apt-get install libssl-dev
```

Step 2. Build slurm

```
tar xvfz slurm-14.11.6.tar.gz 
cd slurm-14.11.6
./configure --with-munge=/usr/local/lib
```
`--with-munge` is important. 

Step 3. Make munge.key 

```
dd if=/dev/random bs=1 count=1024 >/usr/local/etc/munge/munge.key
```
This file should be permissioned 0400 and owned by the user that the munged daemon will run as. Securely propagate this file (e.g., via ssh) to all other hosts within the same security realm.

Step 4. Server Test 

```
sudo ./check.sh 
```

included version is most stable version.

Step 5. Change UID, GID 
서버 및 노드들의 사용자, 그룹 아이디를 동일하게 변경해 준다. 

```
usermod -u <NEWUID> <LOGIN>    
groupmod -g <NEWGID> <GROUP>
find / -user <OLDUID> -exec chown -h <NEWUID> {} \;
find / -group <OLDGID> -exec chgrp -h <NEWGID> {} \;
usermod -g <NEWGID> <LOGIN>
```

Step 6. pdsh 설정 
```
sudo apt install pdsh 
echo "ssh" > /etc/pdsh/rcmd_default
```

nodes에 노드이름을 넣기. 

Step 7. 클라이언트 시작하기 
```
sudo slurmd 
sudo munged 
```

Step 8. scp 사용시 유의사항 

서버 이름이 pascal이라고 할때. 
서버를 계산노드로 사용할때에는 pascal에서 ssh pascal로 한번 접속해서 known_hosts에 등록시켜야 한다. 물론, 다른 계산노드에서 결과를 복사해 오려면 node->pascal 로 ssh접속테스트를 꼭 해야 한다.

또한, 동시접속자수가 문제를 일으킬수도 있다. 이에관한 설정은 다음 문서를 확인하라. 
http://unix.stackexchange.com/questions/196932/how-to-limit-the-number-of-active-logins-per-user

또한, 알수없는 이유로 인해서 scp가 무시되는 경우가 있다. 이 경우에를 방지하기 위해서 서버에 파일이 업로드 되었는가를 검사하고 없으면 scp를 반복하는 방법이 있다.

```
i="0"
while [ $i -lt 10 ]
do
    echo $i
    ssh darwin test -f 'testfile' && i=10 || scp -rpB testfile darwin:
    i=$[$i+1]
done
```

이 코드를 테스트해 본 결과, 루프를 사용한 경우와 그렇지 않는 경우는 각각 100%, 60% 수준이었다.