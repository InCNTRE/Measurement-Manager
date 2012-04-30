#!/usr/bin/perl
#--------------------------------------------------------------------
# Flowvisor.pm
#--------------------------------------------------------------------
package Flowvisor;
use Fvctl;
use Slice;
use strict;
use warnings;
use vars '$AUTOLOAD';    # 'use strict'
use Net::hostent;
use Socket;
use Data::Dumper;

#
# Build a Flowvisor object with information available through XMLRPC
# Will contain nested Slice and Device objects
#

sub new {
    my $class = shift;

    #warn Dumper @_;
    my %args = @_;

    #warn Dumper %args;
    if ( !exists $args{url} ) {
        die "a \$url must be passed to Flowvisor->new()";
    }
    my $self = {
        _url     => undef,    #$args->{url},
        _slices  => undef,
        _devices => undef,
    };
    bless $self, $class;
    $self->_init(@_);

    #warn Dumper $self;
    return $self;
}

# Using a sub process so we can take each variable name
# add the \_ so it can be "private"
sub _init {
    my $self = shift;
    my %pairs = @_;
    foreach my $key ( keys %pairs ) {
        $self->{ "\_" . $key } = $pairs{$key};
    }

    # Pull the hostname out of the url
    if ( $self->get_url() =~ /\/\/(.*):(.*)@(.*):/ ) {
        my $username = $1;
        my $password = $2;
        my $hostname = $3;
        eval( my $host_struct = Net::hostent::gethost($hostname) );
        my $host = $host_struct->name;
        my $addr = inet_ntoa( $host_struct->addr );
        $self->set_ip($addr);
        $self->set_hostname($host);
        $self->set_username($username);
        $self->set_password($password);
    }
}

sub AUTOLOAD {
    my ($self) = @_;
    $AUTOLOAD =~ /.*::get(_\w+)/
      && return $self->{$1};

    $AUTOLOAD =~ /.*::set(_\w+)/
      && do {
        my $self = shift;
        $self->{$1} = "@_";
      }
}

#sub get_slices { $_[0]->{slices} }

sub set_slices {
    my $self   = shift;
    my $arg    = shift;
    my %slices = Fvctl::listSlices($arg);
    # Save the reference in the Flowvisor object
    $self->{_slices} = \%slices;
}

sub set_devices {
    my $self    = shift;
    my $arg     = shift;
    my %devices = Fvctl::listDevices($arg);

    # Save the reference in the Flowvisor object
    $self->{_devices} = \%devices;

    #warn Dumper $self;
}

1;

__END__

# Documentation   ###########################################################

=head1 NAME

GENI::Flowvisor

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 EXAMPLES

=head1 SEE ALSO

=head1 AUTHORS

=cut
