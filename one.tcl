
#creating simulator object
set ns [new Simulator]

#Open Nam trace file
set nf [open prog1.nam w]
$ns namtrace-all $nf

set nd [open prog1.tr w]
$ns trace-all $nd

#finish procedure
proc finish { } {
global ns nf nd
$ns flush-trace
close $nf
close $nd
exec nam prog1.nam &
exec awk -f one.awk prog1.tr &
exit 0
}

#creating nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

#Creating links
$ns duplex-link $n0 $n1 0.9Mb 10ms DropTail
$ns duplex-link $n1 $n2 512Kb 10ms DropTail
$ns queue-limit $n1 $n2 5

#Create UDP agent and attached to node 0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

#set up CBR traffic source at node 0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

#Create a Null agent (a traffic sink) and attach it to node n2
set sink [new Agent/Null]
$ns attach-agent $n2 $sink
$ns connect $udp0 $sink

$ns at 0.2 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"
$ns run
