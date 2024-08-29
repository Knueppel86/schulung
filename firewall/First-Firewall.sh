############################### MY FIRST FIREWALL - PART 1 ###############################
##########################################################################################

###"DNS Server" ### 8.8.8.8 255.0.0.0
###################
#A-Record dns-server 8.8.8.8

### "ISP Router" ###
####################
interface GigabitEthernet0/0/0
ip address 8.8.8.1 255.0.0.0
no shutdown

interface GigabitEthernet0/0/1
ip address 80.242.162.193 255.255.255.252
no shutdown

### "ASA-Firewall" ###
######################
show running-config
#es existieren bereits 2 VLAN's und 1 DHCP pool
#DHCP Pool entfernen
no dhcpd address 192.168.1.5-192.168.1.36 inside
#no dhcpd auto_config outside
#no dhcpd enable inside

#VLAN 1
interface vlan 1
ip address 10.0.0.1 255.0.0.0
no shutdown
nameif inside
security level 100
exit

interface ethernet0/1
switchport mode access
switchport access vlan 1
exit

#VLAN 2
interface vlan 2
ip address 80.242.162.194 255.255.255.252
no shutdown
nameif outside
security level 0
exit

interface ethernet0/0
switchport access vlan 2

show switch vlan

### "Switch" ###
################

vlan 10
name intern
exit

interface vlan 10
ip address 10.0.0.2 255.0.0.0
no shutdown
exit

interface GigabitEthernet0/1
switchport mode access
switchport access vlan 10
exit

interface FastEthernet0/1
switchport mode access
switchport access vlan 10
exit

### "PC" ###
############
# 10.0.0.10 255.0.0.0 10.0.0.1 8.8.8.8

############################### MY FIRST FIREWALL - PART 2 ###############################
##########################################################################################

# route erstellen
route outside 0.0.0.0 0.0.0.0 80.242.162.193

# aktive routen anzeigen
show route

# Netzwerkobjekt erstellen
object network LAN
subnet 10.0.0.0 255.0.0.0
# dynamische NAT Regel erstellen 
nat (inside,outside) dynamic interface

# neue access liste erstellen (ICMP + DNS zulassen)
access-list outside_acl extended permit icmp any any
access-list outside_acl extended permit udp any eq 53 any
# access liste dem interface zuweisen und für welchen Traffic?
access-group outside_acl in interface outside

# aktive access listen anzeigen
show access-list

# BEISPIEL : access liste bzw. Eintrag löschen
no access-list outside_acl extended permit udp any any

############################### MY FIRST FIREWALL - PART 3 ###############################
##########################################################################################

# ASA Firewall Migration to 5506 #

### "ASA-Firewall" ###
######################

interface GigabitEthernet 1/1
ip address 10.0.0.1 255.0.0.0
no shutdown
nameif inside
security level 100
exit

interface GigabitEthernet 1/2
ip address 80.242.162.194 255.255.255.252
no shutdown
nameif outside
security level 0
exit

# route erstellen
route outside 0.0.0.0 0.0.0.0 80.242.162.193

# Netzwerkobjekt erstellen
object network LAN
subnet 10.0.0.0 255.0.0.0
# dynamische NAT Regel erstellen 
nat (inside,outside) dynamic interface

# neue access liste erstellen (ICMP + DNS zulassen)
access-list outside_acl extended permit icmp any any
access-list outside_acl extended permit udp any eq 53 any
# access liste dem interface zuweisen und für welchen Traffic?
access-group outside_acl in interface outside