#!/usr/bin/perl
#--------------------------------------------------------------------
# go.pl
#--------------------------------------------------------------------
use Flowvisor;
use Fvctl;
use Slice;
use Nagios;
use Data::Dumper;
use Auth;
use strict;
use warnings;

#
# Driver for generating the Nagios configuration files
#

# List of XMLRPC urls that are used to query one or multiple Flowvisors
# Enter URL(s) for Flowvisor XMLRPC service using the format below
my @fv_urls = (
    #"https://[fv_username]:[fv_password]\@[hostname]:8080/xmlrpc",
);

# Initialize Nagios object with initial Nagios configuration
# and use to write configuration to file
my $nagios = Nagios->new();

#my @flowvisors;
my %flowvisors;
my %slices;
my %devices;

foreach my $url (@fv_urls) {
    print "Creating new Flowvisor ($url) --------------------------------\n";
    my $fvctl = Fvctl->new( url => $url );
    my $fv = Flowvisor->new( url => $url );

    $fv->set_slices($fvctl);
    $fv->set_devices($fvctl);

    my %s = %{ $fv->get_slices() };
    my %d = %{ $fv->get_devices() };

    #$fv->dump_slices($fvctl);

    #%$flowvisors = (%$fv, %$flowvisors);
    my $tmp = {
        slice_name => $fv->get_hostname(),
        hostname   => $fv->get_hostname(),
        ip         => $fv->get_ip()
    };

    #warn Dumper $tmp;
    my $tmp_slice = Slice->new($tmp);

    #warn Dumper $tmp_slice;
    $flowvisors{$url} = \$fv;

    #warn Dumper \$fv;

    %slices  = ( %s, %slices );
    %devices = ( %d, %devices );
}

#warn Dumper %flowvisors;
my %s;
my %d;

#sub print_slices_devices {
#    foreach my $slice ( keys %slices ) {
#        $s{$slice} = $slices{$slice}{'_hostname'};
#    }
#    foreach my $device ( keys %devices ) {
#        $d{$slice} = $devices{$device}{'_hostname'};
#    }
#}

#print_slices_devices();
foreach my $k ( keys %s ) {
    print $k. "\t\t\t" . $s{$k} . "\n";
}
foreach my $k ( keys %d ) {
    print $k. "\t\t\t" . $d{$k} . "\n";
}

sub remove_duplicates {
    my %new;
    foreach my $slice (@_) {
        my $slices = shift;
        my %hostnames;
        foreach $slice ( keys %$slices ) {
            my $hostname = $slices->{$slice}->get_hostname();
            #warn Dumper $hostname;
            %hostnames = ( ( $hostname => $slices->{$slice} ), %hostnames );
            if ( $hostname eq 'localhost' ) {
                delete $hostnames{$hostname};
            }
        }
    }
}

#remove_duplicates($slices, $flowvisors);
#warn Dumper $slices;


my $slices = \%slices;

sub set_slices() {
	#print "set_slices()\n";
	#warn Dumper \%slices;
    foreach my $slice_name ( keys %$slices ) {
	#warn Dumper $slice_name;
        my $slice    = $slices->{$slice_name};
        my $hostname = $slice->get_hostname();

        #my $port = $slice->get_controller_port();
        #    warn Dumper $slice;
        delete $slices->{$slice_name};

        #$slices->get_hostname().":".$slices->get_controller_port()= $slice;
        $slices->{$hostname} = $slice;
    }

    # We have a hash of slices objects in %slices
    # Iterate through %slices passing each $slices
    # to Nagios to add to the new configuration file
    foreach my $slice_name ( keys %$slices ) {
        my $slice = $slices->{$slice_name};
	#print $slice."\n";
        #print $slice->get_hostname() . "\n";
        if ( $slice->get_hostname() =~ /^(localhost)/ ) {
            #print "MATCHED LOCALHOST\n";
            delete $slices->{$slice_name};
	}
	#print $slice."\n";
	$nagios->define_host($slice);
	$nagios->define_services($slice);
    }
}

# Override slices with any of the flowvisors
#%$slices = (%$flowvisors, %$slices);

#warn Dumper $devices;

my $devices = \%devices;

sub set_devices {
    foreach my $dpid ( keys %$devices ) {
        my $device   = $devices->{$dpid};
        my $hostname = $device->get_hostname();
        delete $devices->{$dpid};
        $devices->{$hostname} = $device;
    }

    # We have an array of device objects in @devices
    # Iterate through @devices passing each $device
    # to Nagios to add to the new configuration file
    foreach my $dpid ( keys %$devices ) {
        my $device = $devices->{$dpid};
	#warn Dumper $device;
        $nagios->define_host($device);
        $nagios->define_services($device);
    }
}

set_slices();
set_devices();
$nagios->write_config();
