set mode quit alldone
set $dir=/home/khoa/mnt/test4
set $nfiles=200
set $meandirwidth=20
set $nthreads=50
set $size1=128k

define fileset name=bigfileset, path=$dir, size=$size1, entries=$nfiles, dirwidth=$meandirwidth, prealloc=80

define process name=fileserver,instances=1
{
        thread name=fileserverthread, memsize=10m, instances=$nthreads
        {
                flowop createfile name=createfile1,filesetname=bigfileset,fd=1
                flowop writewholefile name=wrtfile1,srcfd=1,fd=1,iosize=1m
                flowop closefile name=closefile1,fd=1
                flowop openfile name=openfile1,filesetname=bigfileset,fd=1
                flowop appendfilerand name=appendfilerand1,iosize=16k,fd=1
                flowop closefile name=closefile2,fd=1
                flowop openfile name=openfile2,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile1,fd=1,iosize=1m
                flowop closefile name=closefile3,fd=1
                flowop deletefile name=deletefile1,filesetname=bigfileset
                flowop statfile name=statfile1,filesetname=bigfileset
                flowop finishoncount name=finish, value=1000000
                #So all the above operations will happen together for 3 M (SSD) times
        }
}

system "rm -r /tmp/bigfileset"
create files
#unmount and mount for better stability results
#system "sync"

#system "umount /mnt/EXT4_FS"
#change accordingly for HDD (sdb) and SSD(sdd)
#system "mount -t ext4 /dev/sdd /mnt/EXT4_FS"

#system "sync"
#system "echo 3 > /proc/sys/vm/drop_caches"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"

run

# finishoncount affect the result
# nthreads: fuse doesn't benefit from multithread

#0.000: Allocated 173MB of shared memory
#rm: cannot remove '/tmp/bigfileset': No such file or directory
#0.003: Populating and pre-allocating filesets
#0.003: bigfileset populated: 200 files, avg. dir. width = 20, avg. dir. depth = 1.8, 0 leafdirs, 25.000MB total size
#0.003: Removing bigfileset tree (if exists)
#0.004: Pre-allocating directories in bigfileset tree
#0.006: Pre-allocating files in bigfileset tree
#0.236: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
#0.236: Population and pre-allocation of filesets completed
#0.237: Attempting to create fileset more than once, ignoring
#0.237: Starting 1 fileserver instances
#1.240: Running...
#98.246: Run took 97 seconds...
#98.248: Per-Operation Breakdown
#finish               83325ops      859ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.00ms]
#statfile1            83326ops      859ops/s   0.0mb/s      0.6ms/op [0.00ms - 18.51ms]
#deletefile1          83328ops      859ops/s   0.0mb/s      3.2ms/op [0.00ms - 36.21ms]
#closefile3           83328ops      859ops/s   0.0mb/s      0.8ms/op [0.00ms - 18.39ms]
#readfile1            83333ops      859ops/s 114.7mb/s      1.7ms/op [0.00ms - 32.20ms]
#openfile2            83333ops      859ops/s   0.0mb/s      0.8ms/op [0.00ms - 15.67ms]
#closefile2           83334ops      859ops/s   0.0mb/s      0.8ms/op [0.00ms - 18.59ms]
#appendfilerand1      83338ops      859ops/s   6.7mb/s      3.5ms/op [0.00ms - 35.37ms]
#openfile1            83339ops      859ops/s   0.0mb/s      0.8ms/op [0.00ms - 18.62ms]
#closefile1           83339ops      859ops/s   0.0mb/s      0.8ms/op [0.00ms - 15.58ms]
#wrtfile1             83363ops      859ops/s 107.4mb/s     26.9ms/op [0.00ms - 77.59ms]
#createfile1          83364ops      859ops/s   0.0mb/s      6.3ms/op [0.00ms - 43.13ms]
#98.248: IO Summary: 916725 ops 9450.251 ops/s 859/1718 rd/wr 228.9mb/s  15.4ms/op
#98.248: Shutting down processes

#0.000: Allocated 173MB of shared memory
#rm: cannot remove '/tmp/bigfileset': No such file or directory
#0.003: Populating and pre-allocating filesets
#0.003: bigfileset populated: 200 files, avg. dir. width = 20, avg. dir. depth = 1.8, 0 leafdirs, 25.000MB total size
#0.003: Removing bigfileset tree (if exists)
#0.004: Pre-allocating directories in bigfileset tree
#0.004: Pre-allocating files in bigfileset tree
#0.016: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
#0.016: Population and pre-allocation of filesets completed
#0.017: Attempting to create fileset more than once, ignoring
#0.017: Starting 1 fileserver instances
#1.020: Running...
#3.021: Run took 2 seconds...
#3.022: Per-Operation Breakdown
#finish               83327ops    41660ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.02ms]
#statfile1            83327ops    41660ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.58ms]
#deletefile1          83312ops    41653ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.46ms]
#closefile3           83333ops    41663ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.17ms]
#readfile1            83335ops    41664ops/s 5532.1mb/s      0.0ms/op [0.00ms -  0.49ms]
#openfile2            83338ops    41666ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.84ms]
#closefile2           83338ops    41666ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.18ms]
#appendfilerand1      83338ops    41666ops/s 325.6mb/s      0.0ms/op [0.00ms -  1.64ms]
#openfile1            83339ops    41666ops/s   0.0mb/s      0.0ms/op [0.00ms -  2.00ms]
#closefile1           83339ops    41666ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.14ms]
#wrtfile1             83346ops    41670ops/s 5208.7mb/s      0.1ms/op [0.00ms -  0.56ms]
#createfile1          83347ops    41670ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.47ms]
#3.022: IO Summary: 916692 ops 458310.252 ops/s 41664/83335 rd/wr 11066.4mb/s   0.1ms/op
#3.022: Shutting down processes
