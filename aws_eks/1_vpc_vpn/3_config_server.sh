#!/bin/bash
# Name: config_server.sh
# Owner: Saurav Mitra
# Description: Configure OpenVPN Access Server

admin_pw=${VPN_ADMIN_PASSWORD}
pushd /usr/local/openvpn_as/scripts
./sacli --key "vpn.server.daemon.enable" --value "false" ConfigPut
./sacli --key "cs.tls_version_min" --value "1.2" ConfigPut
./sacli --key "vpn.server.tls_version_min" --value "1.2" ConfigPut
/usr/local/openvpn_as/scripts/ovpnpasswd -u ${VPN_ADMIN_USER} -p ${VPN_ADMIN_PASSWORD}


./sacli --key "vpn.server.routing.gateway_access" --value "true" ConfigPut
./sacli --key "vpn.client.routing.inter_client" --value "false" ConfigPut
./sacli --key "vpn.client.routing.reroute_gw" --value "true" ConfigPut
./sacli --key "vpn.client.routing.reroute_dns" --value "custom" ConfigPut


./sacli --key "vpn.server.routing.private_network.0" --value "${VPC_CIDR_BLOCK}" ConfigPut
./sacli --key "vpn.server.routing.private_access" --value "nat" ConfigPut
./sacli --key "vpn.server.dhcp_option.dns.0" --value "${VPC_NAME_SERVER}" ConfigPut
./sacli --key "vpn.server.dhcp_option.dns.1" --value "8.8.8.8" ConfigPut


./sacli start
popd
