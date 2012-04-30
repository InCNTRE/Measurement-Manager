#!/usr/bin/perl
#--------------------------------------------------------------------
# gen_topo.pl
# This script
#--------------------------------------------------------------------
use Socket;
use Frontier::Client;
use Data::Dumper;
use XML::LibXML;
use Geo::IP;
use Net::DNS;
use Encode;

# Specify the user and password credentials for your Flowvisor
my $user = "";
my $password = "";

my %node;
my %interfaces; 
my %slice;
my %node_dpid;

my $res = Net::DNS::Resolver->new;

$nets{"NLR"}{"net_name"}="NLR";
$nets{"NLR"}{"domain"} = "nlr.net";
$nets{"NLR"}{"fv_url"} = "https://$user:$password\@flowvisor.nlr.net:8080/xmlrpc";
$organization{"NLR"}{"primary_contact"} = "noc\@nlr.net";
$contact{"noc\@nlr.net"}{"last_name"}="NLR NOC";
$contact{"noc\@nlr.net"}{"given_names"}="";
$organization{"NLR"}{"location_name"} = "Cypress,CA,USA";

$organization{"OpenFlow"}{"primary_contact"} = "info\@openflowswitch.org";
$organization{"OpenFlow"}{"location_name"} = "Palo Alto,CA,US";
$contact{"info\@openflowswitch.org"}{"last_name"}="OpenFlow";
$contact{"info\@openflowswitch.org"}{"given_names"}="";
$pop{"OpenFlow"}{"latitude"}=37.430373;
$pop{"OpenFlow"}{"longitude"}=-122.1737;
$pop{"OpenFlow"}{"location_name"}="Palo Alto,CA,US";


$nets{"Indiana"}{"net_name"} = "Indiana";
$nets{"Indiana"}{"domain"} = "indiana.edu";
$nets{"Indiana"}{"fv_url"} = "https://$user:$password\@flowvisor.grnoc.iu.edu:8080/xmlrpc";
$contact{"openflow\@grnoc.iu.edu"}{"last_name"}="Indiana Univ Openflow";
$contact{"openflow\@grnoc.iu.edu"}{"given_names"}="";
$organization{"Indiana"}{"primary_contact"} = "openflow\@grnoc.iu.edu";


$nets{"I2"}{"net_name"} = "I2";
$nets{"I2"}{"domain"} = "net.internet2.edu";
$nets{"I2"}{"fv_url"} = "https://$user:$password\@flowvisor.net.internet2.edu:8080/xmlrpc";
$organization{"I2"}{"primary_contact"} = "noc\@internet2.edu";
$contact{"noc\@internet2.edu"}{"last_name"}="Internet2 NOC";
$contact{"noc\@internet2.edu"}{"given_names"}="";
$organization{"I2"}{"location_name"} = "Ann Arbor,MI,USA";

my $geoinfo_filename="GeoIPCity.dat";
print $geoinfo_filename."\n";
my $gi=Geo::IP->open($geoinfo_filename, GEOIP_STANDARD) or die "cannot open geoip file";


of_init();

foreach my $network_nm (keys %nets) {

  # use Geo location to find location of Org   
  my $geo_org_record=$gi->record_by_name($nets{$network_nm}{"domain"});

#  print Dumper $geo_org_record;
#  print "=====\n";
#  print $nets{$network_nm}{"domain"};
#  print "\n=====\n";

   if (defined $geo_org_record){
    $organization{$network_nm}{"location_name"}=encode("utf8",$geo_org_record->city().",".$geo_org_record->region().",".$geo_org_record->country_code());
    }


my $net_name = $nets{$network_nm}{"net_name"};
my $dom = $nets{$network_nm}{"domain"};
my $flowvisor_rpc = $nets{$network_nm}{"fv_url"};

my $server = Frontier::Client->new( 'url' => $flowvisor_rpc ,
				 'debug' => 0);

my $devices = $server->call('api.listDevices');

print $net_name;
print "\n==========\n";
foreach $device (@$devices) {
  print "$device\n";
  my $device_info = $server->call('api.getDeviceInfo', $device);
  my ($ip,$port) = $device_info->{'remote'} =~ /(\d+\.\d+\.\d+\.\d+):(\d+)$/;
#  print "$ip:$port\n";
  $name = gethostbyaddr(inet_aton($ip), AF_INET);

#print "DPID: $device IP: $ip Hostname: $name  $net_name $dom\n";
   
  # Ignore devices out of my domain
  if ($name) { 
     if ((!($name =~ /$dom/)) && (!($name =~/gigapop.net/)) && (!($name =~/grnoc.iu.edu/)))  {next;}
  } else {$name = $ip;}
  

#print "DPID: $device IP: $ip Hostname: $name  $net_name $dom\n";
  

#  print "Name: $name - $ip\n";
  if (!(defined $name)) { $name = $ip; }
#  print "Name: $name - $ip\n";

print "DPID: $device IP: $ip Hostname: $name  $net_name $dom\n";

  # find location 
  if (!(defined $address_pop{$ip})) {
     geo_loc($ip);
   }

      

#  if ($name =~ /(\w+).of.nlr.net/ || $name =~ /.*\.(\w+).nlrview.nlr.net/ ) {
#     $node{$name}{"pop"} = $1; 
#  } 

  $node{$name}{"pop"} = $address_pop{$ip}; 
  $node{$name}{"domain"} = $dom; 
  $node{$name}{"net_name"} = $net_name;
  $node{$name}{"operational_state"} = "Up";
  $node{$name}{"address"} = $ip;
  $node{$name}{"port_list"} = $device_info->{'portNames'}; 
 
  $node_dpid{$device}{"node_name"} = $name; 
  #if ($name)  {$node_dpid{$device}{"node_name"} = $name;} 
  #else { $node_dpid{$device}{"node_name"} = $ip;}
  $node_dpid{$device}{"address"} = $ip;
  
 #print "Port List: $device_info->{'portNames'}\n";
 #print "=======================\n";


  my @ports2 = split /,/,$device_info->{'portNames'};
    foreach my $port2 (@ports2) {
       my ($real_port2,$port_id2) = $port2 =~ /^([^\(]+)\(([^\)]+)\)/;
       $node{$name}{"real_port"}{$port_id2} = $real_port2;
    }


}

my $slices = $server->call('api.listSlices');
foreach my $slice_name_2  (@$slices) {
   if ($slice_name_2 eq "root") {next;}
   my $slice_info = $server->call('api.getSliceInfo', $slice_name_2);
   $slice_hash{$slice_name_2}{"net_name"} = $net_name;
   $slice_hash{$slice_name_2}{"contact_email"} = $slice_info->{'contact_email'};

   # Define the contact
   $contact{$slice_info->{'contact_email'}}{"last_name"}="Unknown";
   $contact{$slice_info->{'contact_email'}}{"given_names"}="";


   $slice_hash{$slice_name_2}{"controller"} = $slice_info->{'controller_hostname'} . ":" . $slice_info->{'controller_port'};
   #print Dumper %slice_hash;
   my $conn_name = "connection_1";
   my $i = 1; 
   my $sw_list = "";
   my @sw_arr;
   while (defined $slice_info->{$conn_name}) {
   #print "$i\n";
   if ($slice_info->{$conn_name} =~ /^([^-]+)-->/) {
         $dpid = $1;
         $sw_list.=$dpid.",";
         push(@sw_arr,$dpid);
         #print "Slice Name: $slice_name_2 DPID: $dpid\n";
        }
       $i++;
       $conn_name = "connection_" . $i;
   }
  $slice_hash{$slice_name_2}{"switches"} = \@sw_arr;
  $slice_hash{$slice_name_2}{"domain"} = $dom;
}
my $links = $server->call('api.getLinks');

#print Dumper %slice_hash;

foreach $cir (@$links) {
  # don't save bidirctional links  
  if (defined $circuit_hash{$net_name . "-" . $node_dpid{$cir->{'dstDPID'}}{"node_name"} . "-" . $node_dpid{$cir->{'srcDPID'}}{"node_name"}}) {next;}
  # Don't save non of links
   if (($cir->{'srcPort'} < 0) || ($cir->{'dstPort'} < 0)) {next;}
  # Don't save remote links
 if ((not defined $node_dpid{$cir->{'srcDPID'}}{"node_name"}) || (not defined $node_dpid{$cir->{'dstDPID'}}{"node_name"})) { next;}
   

  my $cir_name = $net_name . "-" . $node_dpid{$cir->{'srcDPID'}}{"node_name"} . "-" . $node_dpid{$cir->{'dstDPID'}}{"node_name"};
  $circuit_hash{$cir_name}{"src_name"} = "urn:publicid:IDN+".$node{$node_dpid{$cir->{'srcDPID'}}{"node_name"}}{"domain"}."+component+".$node_dpid{$cir->{'srcDPID'}}{"node_name"};
  $circuit_hash{$cir_name}{"dest_name"} = "urn:publicid:IDN+".$node{$node_dpid{$cir->{'dstDPID'}}{"node_name"}}{"domain"}."+component+".$node_dpid{$cir->{'dstDPID'}}{"node_name"};
  $circuit_hash{$cir_name}{"src_port"} = $node{$node_dpid{$cir->{'srcDPID'}}{"node_name"}}{"real_port"}{$cir->{'srcPort'}};
  $circuit_hash{$cir_name}{"dest_port"} = $node{$node_dpid{$cir->{'dstDPID'}}{"node_name"}}{"real_port"}{$cir->{'dstPort'}}; 
#  $circuit_hash{$cir_name}{"src_port"} = $cir->{'srcPort'};
#  $circuit_hash{$cir_name}{"dest_port"} = $cir->{'dstPort'};
  $circuit_hash{$cir_name}{"domain"} = $dom;
  

}

#print Dumper $links;

}

#print Dumper %node_dpid;

writexml();
indentxml();



sub indentxml{
   my $one=` cat out.xml| xmllint --format - >indented.xml`;
}

sub geo_loc{
   my $ipaddr = shift;


   $geo_record=$gi->record_by_addr($ipaddr);
   if (not defined $geo_record){
         print("NOTICE: Geoip not found for $ipaddr\n"); 
         } else {
    my $pop_name=$geo_record->city()."-".$geo_record->latitude()."-".$geo_record->longitude();
  
     $pop{$pop_name}{"latitude"}=$geo_record->latitude();
     $pop{$pop_name}{"longitude"}=$geo_record->longitude(); 
     $pop{$pop_name}{"location_name"}=encode("utf8",$geo_record->city()."-".$geo_record->region()."-".$geo_record->country_code()."|".$pop_name);   
     $address_pop{$ipaddr} = $pop_name;
   } 

  # is there a LOC recod
   my $name = $res->query($ipaddr,'PTR');
   if ($name) {
      my $loc = $res->query($name, 'LOC');
      if ($loc) {
         ($lat, $lon) = $loc->latlon;
         print "LOC: $name $lat $log\n";
         $pop{$pop_name}{"latitude"}=$lat;     
         $pop{$pop_name}{"longitude"}=$long;
        }
   }

      
}

sub of_init {

   $pop{"Indiana"}{"latitude"}=39.17418;
   $pop{"Indiana"}{"longitude"}=-86.5006;
   $pop{"Indiana"}{"location_name"}="Bloomington,IN,US";

   $pop{"IUPUI"}{"latitude"}=39.774349;
   $pop{"IUPUI"}{"longitude"}=-86.167448;
   $pop{"IUPUI"}{"location_name"}="Indianapolis,IN,USA";
   $address_pop{"149.165.134.68"} = "IUPUI";

   $pop{"NLR_Seattle"}{"latitude"}=47.614457;
   $pop{"NLR_Seattle"}{"longitude"}=-122.338413;
   $pop{"NLR_Seattle"}{"location_name"}="Seattle,WA,USA";
   $address_pop{"216.24.177.40"} = "NLR_Seattle";

   $pop{"NLR_Denver"}{"latitude"}=39.745459;
   $pop{"NLR_Denver"}{"longitude"}=-104.979894;
   $pop{"NLR_Denver"}{"location_name"}="Denver,CO,USA";
   $address_pop{"152.49.23.11"} = "NLR_Denver"; 

   $pop{"NLR_Chicago"}{"latitude"}=41.883542;
   $pop{"NLR_Chicago"}{"longitude"}=-87.639723;
   $pop{"NLR_Chicago"}{"location_name"}="Chicago,IL,USA";
   $address_pop{"152.49.3.12"} = "NLR_Chicago";
   
   $pop{"NLR_Atlanta"}{"latitude"}=33.764796;
   $pop{"NLR_Atlanta"}{"longitude"}=-84.384126;
   $pop{"NLR_Atlanta"}{"location_name"}="Atlanta,GA,USA";
   $address_pop{"152.49.13.12"} = "NLR_Atlanta";

   $pop{"NLR_Sunnvale"}{"latitude"}=37.373833;
   $pop{"NLR_Sunnvale"}{"longitude"}=-121.997288;
   $pop{"NLR_Sunnvale"}{"location_name"}="Sunnyvale,CA,USA";
   $address_pop{"152.49.11.6"} = "NLR_Sunnyvale";

   $pop{"I2_Atlanta"}{"latitude"}=33.758537;
   $pop{"I2_Atlanta"}{"longitude"}=-84.38759;
   $pop{"I2_Atlanta"}{"location_name"}="Atlanta,GA,USA";
   $address_pop{"64.57.16.94"} = "I2_Atlanta";

   $pop{"I2"}{"latitude"}=42.24825;
   $pop{"I2"}{"longitude"}=-83.736393;
   $pop{"I2"}{"location_name"}="Ann Arbor,MI,USA";

   $pop{"NLR"}{"latitude"}=33.816539;
   $pop{"NLR"}{"longitude"}=-118.03617;
   $pop{"NLR"}{"location_name"}="Cypress,CA,USA";



   $contact{"chsmall\@indiana.edu"}{"last_name"}="Small";
   $contact{"chsmall\@indiana.edu"}{"given_names"}="Chris";


}


sub writexml{

  my $fh;
  open ($fh,'+>',"out.xml");
  my $doc = XML::LibXML::Document->new();
  my $geni_aggregate = $doc->createElement('geni_aggregate');
  $geni_aggregate->setAttribute('name','OpenFlow');
  $doc->setDocumentElement($geni_aggregate);

  #add locations
  foreach my $pop_name (keys %pop){
      #print $pop{$pop_name}{"location_name"}." \n"; 
      my $location =$doc->createElement('location');
      $location->setAttribute('name', $pop{$pop_name}{"location_name"});
      #$location->setAttribute('name', $pop_name);
      my $geo_location =$doc->createElement('geo_location');
      $geo_location->setAttribute('latitude', $pop{$pop_name}{"latitude"});
      $geo_location->setAttribute('longitude', $pop{$pop_name}{"longitude"});
      $location->appendChild($geo_location);
      $geni_aggregate->appendChild($location);
  }
  #add contacts
  foreach my $contact_name (keys %contact){
      my $contact_branch=$doc->createElement('contact');
      $contact_branch->setAttribute('email_address',$contact_name);
      $contact_branch->setAttribute('last_name',$contact{$contact_name}{"last_name"});
      $contact_branch->setAttribute('given_names',$contact{$contact_name}{"given_names"});
      $geni_aggregate->appendChild($contact_branch);
  }
  #add organizations
  foreach my $org_name (keys %organization){
      my $org_branch=$doc->createElement('organization');
      $org_branch->setAttribute('name',$org_name);

      my $primary_contact=$doc->createElement('primary_contact_email');
      my $primary_contact_text = XML::LibXML::Text->new($organization{$org_name}{"primary_contact"});
      $primary_contact->appendChild($primary_contact_text);
      $org_branch->appendChild($primary_contact);

      my $org_location=$doc->createElement('location_name');
      my $org_location_text=XML::LibXML::Text->new($organization{$org_name}{"location_name"});
      $org_location->appendChild($org_location_text);
      $org_branch->appendChild($org_location);

      #this is optional
      if (defined $organization{$org_name}{"parent_organization"}){
           my $parent_org=$doc->createElement('parent_organization_name');
           my $parent_org_text=XML::LibXML::Text->new($organization{$org_name}{"parent_organization"});
           $parent_org->appendChild($parent_org_text);
           $org_branch->appendChild($parent_org);

      }


      $geni_aggregate->appendChild($org_branch);
  }
  ## add pop
  foreach my $pop_name (keys %pop){
      my $pop_branch=$doc->createElement('point_of_presence');
            $pop_branch->setAttribute('name',$pop_name);
      $pop_branch->setAttribute('location_name',$pop{$pop_name}{"location_name"});
      # we will not make the translator easier by adding an org here!
      $geni_aggregate->appendChild($pop_branch);
  }
  ## add devices!
  foreach my $node_name (keys %node){
     my $node_branch=$doc->createElement('device');
     my $domain_name = $node{$node_name}{"domain"};
     $node_branch->setAttribute('name',"urn:publicid:IDN+$domain_name+component+".$node_name);

     #device location is special! since it can be either a pop or a parent device 
     my $node_location=$doc->createElement('device_location');
     my $pop_name=$doc->createElement('pop_name');
     #my $pop_name_text=XML::LibXML::Text->new($pop{$node{$node_name}{"pop"}}{"location_name"});
     my $pop_name_text=XML::LibXML::Text->new($node{$node_name}{"pop"});
     $pop_name->appendChild($pop_name_text);
     $node_location->appendChild($pop_name);
     $node_branch->appendChild($node_location);

     #OpenFlow IS the operator
     my $node_operator=$doc->createElement('operator_org_name');
     my $node_operator_text=XML::LibXML::Text->new('OpenFlow');
     $node_operator->appendChild($node_operator_text);
     $node_branch->appendChild($node_operator);


     my $device_type=$doc->createElement('device_type');
     my $device_type_text=XML::LibXML::Text->new("switch");
     $device_type->appendChild($device_type_text);
     $node_branch->appendChild($device_type);

     my $dns_name=$doc->createElement('dns_name');
     my $dns_name_text=XML::LibXML::Text->new($node_name);
     $dns_name->appendChild($dns_name_text);
     $node_branch->appendChild($dns_name);

     if(defined $node{$node_name}{"operational_state"}){
       my $operational_state=$doc->createElement('operational_state');
       my $operational_state_text=XML::LibXML::Text->new( $node{$node_name}{"operational_state"});
       $operational_state->appendChild($operational_state_text);
       $node_branch->appendChild($operational_state);
       #print "doing operational state!\n";
     }

    #now we will add the ports 
    print "Node: $node_name Port: $node{$node_name}{\"port_list\"}\n"; 

    my @ports = split /,/,$node{$node_name}{"port_list"};
    foreach my $port (@ports) {
       my ($real_port,$port_id) = $port =~ /^([^\(]+)\(([^\)]+)\)/;
       if ($real_port eq "local") { next; }
       #print "Real port: $real_port Port ID: $port_id\n";
     my $interface_branch=$doc->createElement('interface');
     $interface_branch->setAttribute('name',$real_port);
     #now the address
     my $net_addr_branch=$doc->createElement('net_addr');
     my $net_addr_type_branch=$doc->createElement('net_addr_type');
     my $net_addr_type_text=XML::LibXML::Text->new("ipv4");
     $net_addr_type_branch->appendChild($net_addr_type_text);
     $net_addr_branch->appendChild( $net_addr_type_branch);
     my $addr_branch=$doc->createElement('addr');
     my $addr_text=XML::LibXML::Text->new( $node{$node_name}{"address"});
     $addr_branch->appendChild($addr_text);
     $net_addr_branch->appendChild( $addr_branch);
     my $netmask_branch=$doc->createElement('netmask_len');
     my $netmask_text=XML::LibXML::Text->new( "32");
     $netmask_branch->appendChild($netmask_text);
     $net_addr_branch->appendChild( $netmask_branch);

     $interface_branch->appendChild($net_addr_branch);
     $node_branch->appendChild($interface_branch);
     }

     $geni_aggregate->appendChild($node_branch);
  }
  #now the slices!
  foreach my $slice_name (keys %slice_hash){
     my $slice_branch=$doc->createElement('slice');
     #$slice_branch->setAttribute('name',$slice_name);
     $slice_branch->setAttribute('name',"urn:publicid:IDN+".$slice_hash{$slice_name}{"domain"}."+slice+".$slice_name);

     #planetlab is the operator
     my $slice_operator=$doc->createElement('operator_org_name');
     my $slice_operator_text=XML::LibXML::Text->new('OpenFlow');
     $slice_operator->appendChild($slice_operator_text);
     $slice_branch->appendChild($slice_operator);

     my $slice_contact=$doc->createElement('primary_contact_email');
     my $slice_contact_text=XML::LibXML::Text->new($slice_hash{$slice_name}{"contact_email"});
     $slice_contact->appendChild($slice_contact_text);
     $slice_branch->appendChild($slice_contact);
     #now the devices in the slice
     #print Dumper %node_dpid;
     foreach my $sl_dpid (@ { $slice_hash{$slice_name}{switches}} ){
        my $device_node=$doc->createElement('device_names');
        #print "SL: $slice_name $sl_dpid\n";
        my $device_name = $node_dpid{$sl_dpid}{"node_name"};
        my $device_node_text=XML::LibXML::Text->new("urn:publicid:IDN+".$node{$device_name}{"domain"}."+component+".$device_name);
        $device_node->appendChild($device_node_text);
       $device_node->appendChild($device_node_text);
        $slice_branch->appendChild($device_node);

     }


     $geni_aggregate->appendChild($slice_branch);
  }



  my $net_topology=$doc->createElement('net_topology');

  foreach $net (keys %nets) {
  #now the net topology
  my $network=$doc->createElement('network');
  my $network_name = $nets{$net}{"net_name"} . "_net";
  $network->setAttribute('name',$network_name);
  my $network_op_branch=$doc->createElement('operator_org_name');
  my $network_op_branch_text=XML::LibXML::Text->new('OpenFlow');
  $network_op_branch->appendChild($network_op_branch_text);
  $network->appendChild($network_op_branch);
  #$net_topology->appendChild($network);



  foreach my $ci_name (keys %circuit_hash) {
  if ($nets{$net}{"domain"} ne $circuit_hash{$ci_name}{"domain"}) {next;}


  #now the circuit in the network
  my $circuit=$doc->createElement('circuit');

  if ($circuit_hash{$ci_name}{"src_name"} eq $circuit_hash{$ci_name}{"dest_name"}) {next;}
  print "CIC:" . $circuit_hash{$ci_name}{"src_name"} . ":" . $circuit_hash{$ci_name}{"dest_name"} . "\n";




  # Pattern is "net-node1-node2"
 # my $circuit_text = XML::LibXML::Text->new("urn:publicid:IDN+".$circuit_hash{$ci_name}{"domain"}."+circuit+".$ci_name);
  my $circuit_text = "urn:publicid:IDN+".$circuit_hash{$ci_name}{"domain"}."+circuit+".$ci_name;
  #my $circuit_text2 = XML::LibXML::Text->new($circuit_test2);
  $circuit->setAttribute('name',$circuit_text);


  my $src_endpoint=$doc->createElement('endpoint');

  $src_endpoint->setAttribute('name',$circuit_hash{$ci_name}{"src_name"});
  $src_endpoint->setAttribute('interface_name',$circuit_hash{$ci_name}{"src_port"});

  $circuit->appendChild($src_endpoint);

  my $dest_endpoint=$doc->createElement('endpoint');

 
  $dest_endpoint->setAttribute('name',$circuit_hash{$ci_name}{"dest_name"});
  $dest_endpoint->setAttribute('interface_name',$circuit_hash{$ci_name}{"dest_port"});

  $circuit->appendChild($dest_endpoint);
  $network->appendChild($circuit);
  }
  $net_topology->appendChild($network);

  }
  $geni_aggregate->appendChild($net_topology);


  #finalize by printing
  print $fh $doc->toString;

}

sub numeric2dottedipv4{
   my $address=shift;
   return ($address>>24).".".(($address & 0xFFFFFF)>>16).".".(($address & 0xFFFF)>>8).".".($address & 0xFF);
}


