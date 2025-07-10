set mode quit alldone
set $dir=/mnt/leanfs
set $nfiles=15000
set $meandirwidth=15000
set $nthreads=16
set $size1=16k

define fileset name=bigfileset, path=$dir, size=$size1, entries=$nfiles, dirwidth=$meandirwidth, prealloc=80

define process name=mailserver,instances=1
{
        thread name=mailserverthread, memsize=10m, instances=$nthreads
        {
                flowop deletefile name=deletefile1,filesetname=bigfileset
                flowop createfile name=createfile2,filesetname=bigfileset,fd=1
                flowop appendfilerand name=appendfilerand2,iosize=16k,fd=1
                flowop fsync name=fsyncfile2,fd=1
                flowop closefile name=closefile2,fd=1
                flowop openfile name=openfile3,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile3,fd=1,iosize=1m
                flowop appendfilerand name=appendfilerand3,iosize=16k,fd=1
                flowop fsync name=fsyncfile3,fd=1
                flowop closefile name=closefile3,fd=1
                flowop openfile name=openfile4,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile4,fd=1,iosize=1m
                flowop closefile name=closefile4,fd=1
                flowop finishoncount name=finish, value=1000000
                #so that all the above operations togeteher run 1 M (SSD) ops
        }
}

system "rm -r /tmp/bigfileset"
create files
system "sync"
#system "umount /mnt/EXT4_FS/"
#change accordingly for HDD (sdb) and SSD(sdd)
#system "mount -t ext4 /dev/sdd /mnt/EXT4_FS"

#system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"

run 60

#0.000: Allocated 173MB of shared memory
#rm: cannot remove '/tmp/bigfileset': No such file or directory
#0.003: Populating and pre-allocating filesets
#0.006: bigfileset populated: 15000 files, avg. dir. width = 15000, avg. dir. depth = 1.0, 0 leafdirs, 234.375MB total size
#0.006: Removing bigfileset tree (if exists)
#0.007: Pre-allocating directories in bigfileset tree
#0.007: Pre-allocating files in bigfileset tree
#2.659: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
#2.659: Population and pre-allocation of filesets completed
#2.729: Attempting to create fileset more than once, ignoring
#2.729: Starting 1 mailserver instances
#3.731: Running...
#42.734: Run took 39 seconds...
#42.735: Per-Operation Breakdown
#finish               71425ops     1831ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.01ms]
#closefile4           71425ops     1831ops/s   0.0mb/s      0.2ms/op [0.03ms - 16.34ms]
#readfile4            71426ops     1831ops/s  28.3mb/s      0.3ms/op [0.05ms - 16.49ms]
#openfile4            71427ops     1831ops/s   0.0mb/s      0.4ms/op [0.05ms - 20.99ms]
#closefile3           71428ops     1831ops/s   0.0mb/s      0.2ms/op [0.02ms - 15.95ms]
#fsyncfile3           71429ops     1831ops/s   0.0mb/s      0.2ms/op [0.02ms - 15.79ms]
#appendfilerand3      71430ops     1831ops/s  14.4mb/s      0.9ms/op [0.10ms - 43.87ms]
#readfile3            71430ops     1831ops/s  28.4mb/s      0.3ms/op [0.00ms - 16.28ms]
#openfile3            71431ops     1831ops/s   0.0mb/s      0.4ms/op [0.05ms - 18.16ms]
#closefile2           71432ops     1831ops/s   0.0mb/s      0.2ms/op [0.02ms - 16.35ms]
#fsyncfile2           71432ops     1831ops/s   0.0mb/s      0.2ms/op [0.04ms - 15.88ms]
#appendfilerand2      71434ops     1832ops/s  14.3mb/s      0.8ms/op [0.08ms - 43.61ms]
#createfile2          71436ops     1832ops/s   0.0mb/s      2.4ms/op [0.33ms - 52.72ms]
#deletefile1          71440ops     1832ops/s   0.0mb/s      1.7ms/op [0.17ms - 54.72ms]
#42.735: IO Summary: 928600 ops 23808.797 ops/s 3663/3663 rd/wr  85.4mb/s   2.1ms/op
#42.735: Shutting down processes

#0.000: Allocated 173MB of shared memory
#rm: cannot remove '/tmp/bigfileset': No such file or directory
#0.003: Populating and pre-allocating filesets
#0.006: bigfileset populated: 15000 files, avg. dir. width = 15000, avg. dir. depth = 1.0, 0 leafdirs, 234.375MB total size
#0.006: Removing bigfileset tree (if exists)
#0.007: Pre-allocating directories in bigfileset tree
#0.007: Pre-allocating files in bigfileset tree
#0.407: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
#0.407: Population and pre-allocation of filesets completed
#0.724: Attempting to create fileset more than once, ignoring
#0.724: Starting 1 mailserver instances
#1.726: Running...
#177.737: Run took 176 seconds...
#177.738: Per-Operation Breakdown
#finish               71426ops      406ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.01ms]
#closefile4           71426ops      406ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.17ms]
#readfile4            71426ops      406ops/s   8.0mb/s      0.0ms/op [0.00ms -  6.67ms]
#openfile4            71426ops      406ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.35ms]
#closefile3           71426ops      406ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.05ms]
#fsyncfile3           71429ops      406ops/s   0.0mb/s     19.2ms/op [7.16ms - 70.38ms]
#appendfilerand3      71429ops      406ops/s   3.2mb/s      0.0ms/op [0.00ms - 10.63ms]
#readfile3            71429ops      406ops/s   7.1mb/s      0.0ms/op [0.00ms - 10.59ms]
#openfile3            71429ops      406ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.34ms]
#closefile2           71429ops      406ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.08ms]
#fsyncfile2           71440ops      406ops/s   0.0mb/s     19.6ms/op [9.12ms - 71.13ms]
#appendfilerand2      71440ops      406ops/s   3.2mb/s      0.0ms/op [0.00ms -  0.08ms]
#createfile2          71440ops      406ops/s   0.0mb/s      0.0ms/op [0.01ms -  3.63ms]
#deletefile1          71440ops      406ops/s   0.0mb/s      0.2ms/op [0.01ms -  4.88ms]
#177.738: IO Summary: 928609 ops 5275.849 ops/s 812/812 rd/wr  21.4mb/s   9.8ms/op
#177.738: Shutting down processes
