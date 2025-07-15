set mode quit alldone
set $dir=/mnt/leanfs
set $iosize=4k
set $nfiles=1
set $meandirwidth=1
set $nthreads=1
#I/O amount equal to 60 G(SSD)
set $iterations=26214400

define file name=bigfileset, path=$dir, size=10m, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=$iosize, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop write name=write-file, filesetname=bigfileset, random, iosize=$iosize, iters=$iterations, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}
create files

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "iostat -xy 1 > stat.log &"
run 10
