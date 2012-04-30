#!/usr/bin/perl
#--------------------------------------------------------------------
# Slice.pm
#--------------------------------------------------------------------
package Slice;
use strict;
use warnings;
use vars '$AUTOLOAD';    # 'use strict'
use Data::Dumper;
use Net::hostent;
use Socket;

#
# Creates Slice (controller) objects
#

sub new {
    my $class = shift;
    my $args  = shift;

    if ( !exists $args->{slice_name} ) {
        die "a \$slice_name must be passed to Slice->new()";
    }
    my $self = { _slice_name => $args->{slice_name}, };
    bless $self, $class;
    $self->_init($args);

    #warn Dumper $self;
    return $self;
}

sub _init {

    #print "init()\n";
    #warn Dumper \@_;
    my $self = shift;
    my $args = shift;
    foreach my $key ( keys %{$args} ) {
        $self->{ "\_" . $key } = ${$args}{$key};
    }

    my $host = $self->get_controller_hostname || $self->get_hostname;

    #eval ( Net::hostent::gethost($host) );
    #print "Continuing after error: $@" if $@;

    #    if(!$@){
    #	print "Problem with DNS/IP - $host: $@\n";
    #    }

    eval( my $host_struct = Net::hostent::gethost($host) );

    #    if($@){
    #	if($@ eq undef) {
    #	    print "Error: Cannot resolve hostname in Slice.pm at line 68\n";
    #	}
    #   }
    #    else{
    my $hostname = $host_struct->name;
    my $ip       = inet_ntoa( $host_struct->addr );
    $self->set_ip($ip);
    $self->set_hostname($hostname);

    #    }
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

1;
