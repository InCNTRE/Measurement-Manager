#!/usr/bin/perl
#--------------------------------------------------------------------
# Device.pm
#--------------------------------------------------------------------
package Device;
use strict;
use warnings;
use vars '$AUTOLOAD';    # 'use strict'
use Net::hostent;
use Socket;
use Data::Dumper;
use Carp;

#
# Constructs Device (switch) objects
#

sub new {
    my $class = shift;
    my $args  = shift;

    if ( !exists $args->{dpid} ) {
        die "a \$dpid must be passed to Device->new()";
    }
    my $self = { _dpid => $args->{dpid}, };
    bless $self, $class;
    $self->_init($args);
    return $self;
}

sub _init {
    my $self = shift;
    my $args = shift;
    foreach my $key ( keys %{$args} ) {
        $self->{ "\_" . $key } = ${$args}{$key};

    }

    # Using RegEx to get the remote url of the switch e.g. 216.24.177.40
    # and the remote Listener psuedo-url e.g. 6633
    # combining them into the url that dpctl uses to query the switch
    # for statistics in the form
    # tcp:216.24.177.40:6633
    # then storing this url in the device object under the dpctl attribute
    # '_remote' => '/156.56.5.252:6633-->/216.24.177.40:49180',
    my $remote = $self->get_remote();

    #warn Dumper $remote;
    my ( $local_ip, $remote_port, $remote_ip, $local_port ) = $remote =~
      /(\d+\.\d+\.\d+\.\d+):(\d+)\-\-\>\/(\d+\.\d+\.\d+\.\d+):(\d+)$/;

    #print "local_ip: $local_ip\n";
    #print "remote_port: $remote_port\n";
    #print "remote_ip: $remote_ip\n";
    #print "local_port: $local_port\n";

    #warn Dumper $remote_ip;
    # Set the IP_addr/port/hostnamehostname of the switch
    eval( my $host_struct = Net::hostent::gethost($remote_ip) );

    #warn Dumper $host_struct;
    #    if ( $@ ){
    #	print "$@";
    #	print "Enter hostname for $remote_ip: \n";
    #	my $hostname = <STDIN>;
    #	$hostname = chomp( $hostname );
    #	my $ip = $remote_ip;
    #	$self->set_ip($ip);
    #	$self->set_hostname($hostname);
    #	$self->set_listening_port($remote_port);
    #   }
    #   else {
    my $hostname = $host_struct->name;
    my $ip       = inet_ntoa( $host_struct->addr );
    $self->set_ip($ip);
    $self->set_hostname($hostname);
    $self->set_listening_port($remote_port);

    #  }

    # Set the IP_addr/port/hostname of the switch's OpenFlow controller
    eval( $host_struct = Net::hostent::gethost($local_ip) );

    #warn Dumper $host_struct;
    my $host = $host_struct->name;
    my $addr = inet_ntoa( $host_struct->addr );
    $self->set_controller_ip($addr);
    $self->set_controller_hostname($host);
    $self->set_controller_port($local_port);
    $self->set_dpctl( 'tcp:' . $ip . ':' . $remote_port );
}

sub AUTOLOAD {
    my ($self) = @_;
    $AUTOLOAD =~ /.*::get(_\w+)/
      && return $self->{$1};

    $AUTOLOAD =~ /.*::set(_\w+)/
      && do { 
	  my $self = shift; 
	  my @args = @_; 
	  $self->{$1} = "@args"; }
}

1;
