set $dir=/home/khoa/mnt/test4
set $meandirwidth=1000
set $nfiles=10000
set $filesize=128k
set $nthreads=1

define fileset name=bigfileset,path=$dir,size=$filesize,entries=$nfiles,dirwidth=$meandirwidth,prealloc=100

define process name=examinefiles,instances=1
{
  thread name=examinefilethread, memsize=10m,instances=$nthreads
  {
    flowop statfile name=statfile1,filesetname=bigfileset
  }
}

run 10
