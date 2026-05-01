#!/usr/bin/env python3

# Create script to sync pyATS results to NetBox

# como executar
# chmod +x sync_to_netbox.py
# python3 sync_to_netbox.py

import requests
import json
from pyats import topology

# NetBox configuration
NETBOX_URL = "http://192.168.249.175:8000"
NETBOX_TOKEN = "3QCovwiemJCScq6kk5OSefbJKr4NzEQ2Cr8tufOt"
headers = {
    "Authorization": f"Token {NETBOX_TOKEN}",
    "Content-Type": "application/json"
}

# Load testbed
testbed = topology.loader.load('testbed.yaml')

# Connect and collect data
device = testbed.devices['SW1']
device.connect()

# Parse interfaces
interfaces = device.parse('show interfaces')

# Update NetBox
for intf_name in interfaces['interfaces']:
    intf_data = interfaces['interfaces'][intf_name]
    
    # Create/update interface in NetBox
    data = {
        "name": intf_name,
        "type": "other",
        "enabled": intf_data['enabled'],
        "mtu": intf_data.get('mtu', 1500),
        "description": intf_data.get('description', '')
    }
    
    # API call to NetBox
    response = requests.post(
        f"{NETBOX_URL}/api/dcim/interfaces/",
        headers=headers,
        json=data
    )
    
    print(f"Updated interface: {intf_name} - Status: {response.status_code}")

device.disconnect()