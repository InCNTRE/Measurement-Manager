#!/usr/bin/perl
#--------------------------------------------------------------------
# Config.pm
#--------------------------------------------------------------------
package Nagios::Config;
use strict;
use warnings;
use Data::Dumper;

#
# Contains Nagios config information
#

#		Nagios::write_config({
#			type=>'slice',
#			hostname=>$slice->hostname,
#			ip=>$slice->ip,
#			port=>$slice->port
#			});

sub new {
    my $class = shift;
    my $self  = shift;

    #my $type = $args->{type};
    #my $hostname = $args->{hostname};
    #my $ip = $args->{ip};
    #my $port = $args->{port};
    bless $self, $class;

    # Configuration string to be written to a .cfg file
    my $config = "";
    my $hosts  = "";
    $self->{config} = $config;

    # Name of output.cfg file
    my $config_file = "output.cfg";
    $self->{config_file} = $config_file;

    my $contact_groups = "openflow";
    $self->{contact_groups} = $contact_groups;

    my $slice_commands = {
        'OF_SERVICE' => ' check_tcp!' . '6644' . '!',
        'CPU_LOAD'   => 'check_nrpe!check_load!-w 75% ! -c 90%!',
        'DISK_SPACE' => 'check_nrpe!check_disk!-w 30%!',
    };
    $self->{slice_commands} = $slice_commands;

    my $device_commands = {
        'OF_FLOWS'   => 'check_of_flows',
        'CPU'        => 'check_cpu!of-snoop!hp!\" 75\"! 80',
        'OF_HITRATE' => 'check_of_hitrate',
    };
    $self->{device_commands} = $device_commands;
    return $self;
}

sub config { shift->{config} }

sub define_host {
    my $self           = shift;
    my $hostname       = $self->{hostname};
    my $ip             = $self->{ip};
    my $contact_groups = $self->{contact_groups};

    my $host =
        "define host{\n"
      . "\tuse\t\t\tgeneric-host\n"
      . "\thost_name\t\t"
      . $hostname . "\n"
      . "\talias\t\t\t"
      . $hostname . "\n"
      . "\taddress\t\t\t"
      . $ip . "\n"
      . "\tcontact_groups\t\t"
      . $contact_groups . "\n" . "}\n\n";
    return $host;
}

sub define_service {
    my $self           = shift;
    my $hostname       = $self->{hostname};
    my %commands       = $self->{commands};
    my $contact_groups = $self->{contact_groups};
    my $service;

    foreach my $command ( keys %commands ) {
        $service =
            "define service{\n"
          . "\tuse\t\tgeneric-service\n"
          . "\thost_name\t\t"
          . $hostname . "\n"
          . "\tservice_description\t\t"
          . $command . "\n"
          . "\tcheck_command\t\t"
          . $commands{$command} . "\n"
          . "\tcontact_groups\t\t"
          . $contact_groups . "\n"
          . "\tnotification_options\t\tw,u,c,r\n"
          . "\tcheck_period\t\t24x7\n"
          . "\tnotification_period\t\t24x7\n"
          . "\tnormal_check_interval\t\t1\n"
          . "\tretry_check_interval\t\t1\n" . "}\n\n";
        return $service;
    }
}

1;
