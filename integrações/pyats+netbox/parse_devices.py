#!/usr/bin/env python3
from pyats import topology
from genie.conf import Genie

# Load testbed
testbed = topology.loader.load('testbed.yaml')

# Connect to device
device = testbed.devices['SW1']
device.connect()

# Parse show version
output = device.parse('show version')
print(f"Hostname: {output['version']['hostname']}")
print(f"Version: {output['version']['version']}")
print(f"Uptime: {output['version']['uptime']}")

# Parse show interfaces
#interfaces = device.parse('show interfaces')
#for intf in interfaces['interfaces']:
#    print(f"Interface: {intf}")
#    print(f"  Status: {interfaces['interfaces'][intf]['oper_status']}")

device.disconnect()