# setup-slurm

[SLURM](https://slurm.schedmd.com/)은 잘 알려진 워크로드 매니저이고 [위키](https://en.wikipedia.org/wiki/Slurm_Workload_Manager)에 따르면 전세계 수퍼컴퓨터의 60%가 이것을 사용하고 있다고 합니다. 시작에 앞서서 사용자 아이디를 생성하고, 다음과 같이 SU권한을 주도록 합니다.

```shell
sudo adduser <username> sudo
```

또한, 모든 컴퓨터들이 상호간에 ssh접속을 할 수 있는지 확인합시다. slurm server에서는 self-connection도 확인해야 합니다.

**Step 1. Install dependency**

```shell
sudo apt-get install libssl-dev
```

**Step 2. Build slurm**

Package directory에 들어 있는 slurm-14.11.6.tar.gz 파일을 작업디렉토리로 복사하고, 다음 명령을 따라서 압축을 풀이합니다. 

```shell
tar xvfz slurm-14.11.6.tar.gz 
cd slurm-14.11.6
./configure --with-munge=/usr/local/lib
```
`--with-munge` is important. 

**Step 3. Make munge.key**

>  MUNGE (*MUNGE Uid 'N' Gid Emporium*) is an authentication service for creating and validating credentials.  - from https://github.com/dun/munge

```shell
dd if=/dev/random bs=1 count=1024 >/usr/local/etc/munge/munge.key
```
This file should be permissioned 0400 and owned by the user that the munged daemon will run as. Securely propagate this file (e.g., via ssh) to all other hosts within the same security realm.

**Step 4. Server Test** 

서버의 설치가 완료 되었다면 check.sh 스크립트를 이용해서 점검합니다.

```shell
sudo ./check.sh 
```

Included version is most stable version.

**Step 5. Change UID, GID**

서버 및 노드들의 사용자, 그룹 아이디를 모두 동일하게 변경해 줍니다.

```shell
usermod -u <NEWUID> <LOGIN>    
groupmod -g <NEWGID> <GROUP>
find / -user <OLDUID> -exec chown -h <NEWUID> {} \;
find / -group <OLDGID> -exec chgrp -h <NEWGID> {} \;
usermod -g <NEWGID> <LOGIN>
```

**Step 6. pdsh 설정**
```shell
sudo apt install pdsh 
echo "ssh" > /etc/pdsh/rcmd_default
```

nodes에 노드이름을 넣기 

**Step 7. 클라이언트 시작**
```shell
sudo slurmd 
sudo munged 
```

**Step 8. SCP 사용시 유의사항**

서버 이름이 pascal이라고 할때, 서버를 계산노드로 사용할때에는 pascal에서 ssh pascal로 한번 접속해서 known_hosts에 등록시켜야 합니다. 물론, 다른 계산노드에서 결과를 복사해 오려면 node->pascal 로 ssh접속테스트를 꼭 해야 합니다. 또한, 동시접속자수가 문제를 일으킬 수도 있습니다. 이에 관한 설정은 다음 문서를 확인하세요.

http://unix.stackexchange.com/questions/196932/how-to-limit-the-number-of-active-logins-per-user

또한, 알 수 없는 이유로 인해서 scp가 무시되는 경우가 있습니다. 이 경우를 방지하기 위해 서버에 파일이 업로드 되었는가를 검사하고 없으면 scp를 반복하는 방법이 있습니다.

```sh
i="0"
while [ $i -lt 10 ]
do
    echo $i
    ssh darwin test -f 'testfile' && i=10 || scp -rpB testfile darwin:
    i=$[$i+1]
done
```

이 코드를 테스트해 본 결과, 루프를 사용한 경우와 그렇지 않는 경우는 각각 전송 성공률이 100% 및 60% 이었습니다. scp를 이용한 파일 복사가 실패확률이 60%나 된다는 사실이 놀랍습니다. 이것은 다수의 컴퓨팅 노드들이 동시에 서버로 파일을 전송하고자 하는 시도를 ssh서버가 마치 *공격*으로 인식하고 방어하고 있기 때문일 것으로 생각됩니다.

