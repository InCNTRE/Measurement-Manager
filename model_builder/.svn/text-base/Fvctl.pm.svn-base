#!/usr/bin/perl
#--------------------------------------------------------------------
# Fvctl.pm
#--------------------------------------------------------------------
package Fvctl;
use Slice;
use Device;
use strict;
use warnings;
use vars '$AUTOLOAD';    # 'use strict'
use Data::Dumper;
use Frontier::Client;

#
# Methods to query the Flowvisor similar to the fvctl utility
# Uses the XMLRPC Frontier::Client
#

sub new {
    my $class = shift;
    my %args  = @_;
    if ( !exists $args{url} ) { 
	die "a \$url must be passed to FVCTL->new()"; 
    }
    my $self = { _server => Frontier::Client->new( url => $args{url} ), };
    bless $self, $class;
    $self->_init(%args);

    #warn Dumper $self;
    return $self;
}

sub _init {
    my ( $self, %args ) = @_;
    foreach my $key ( keys %args ) {
        $self->{ "\_" . $key } = $args{$key};
    }
}

sub AUTOLOAD {
    my ($self) = @_;

    $AUTOLOAD =~ /.*::get(_\w+)/
      && return $self->{$1};

    $AUTOLOAD =~ /.*::set(_\w+)/
      && do { 
	  my $self = shift; 
	  $self->{$1} = "@_"; }
}

sub get_slices { $_[0]->{slices} }

sub set_slices {
    print "Entered set_slices()\n";

    #my $self = shift;
    #$self->{slices} = @_;
}

sub listSlices {
    my $self       = shift;
    my $slice_list = $self->get_server->call('api.listSlices');
    my $slice;
    my %slices;
    my $resp;
    foreach my $slice_name (@$slice_list) {
        eval( $resp =
              $self->get_server->call( 'api.getSliceInfo', $slice_name ) );

        #warn Dumper $resp;
        $resp->{slice_name} = $slice_name;
        $slice = Slice->new($resp);
        $slices{$slice_name} = $slice;
    }

    #warn Dumper %slices;
    return %slices;
}

sub listDevices {
    my $self        = shift;
    my $device_list = $self->get_server->call('api.listDevices');
    my $device;
    my %devices;
    my $resp;

    #warn Dumper $device_list;
    foreach my $dpid (@$device_list) {
        eval( $resp = $self->get_server->call( 'api.getDeviceInfo', $dpid ) );

        #warn Dumper $resp;
        $resp->{dpid} = $dpid;
        $device = Device->new($resp);

        #push(@slices,$slice);
        $devices{$dpid} = $device;
    }

    #warn Dumper %slices;
    return %devices;
}

1;
