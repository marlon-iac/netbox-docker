#!/usr/bin/env python3

# Como executar:
# chmod +x test_network.py
# python3 test_network.py --testbed testbed.yaml

from pyats import aetest
from genie.testbed import load

class CommonSetup(aetest.CommonSetup):
    @aetest.subsection
    def connect_to_devices(self, testbed):
        for device in testbed.devices.values():
            device.connect()

class InterfaceTest(aetest.Testcase):
    @aetest.setup
    def setup(self, testbed):
        self.device = testbed.devices['SW1']
    
    @aetest.test
    def test_interfaces_up(self):
        output = self.device.parse('show interfaces')
        failed_interfaces = []
        
        for intf in output['interfaces']:
            status = output['interfaces'][intf]['oper_status']
            if status != 'up':
                failed_interfaces.append(intf)
        
        if failed_interfaces:
            self.failed(f"Interfaces down: {failed_interfaces}")
        else:
            self.passed("All interfaces are up")

class CommonCleanup(aetest.CommonCleanup):
    @aetest.subsection
    def disconnect_from_devices(self, testbed):
        for device in testbed.devices.values():
            device.disconnect()

if __name__ == '__main__':
    import argparse
    from pyats.topology import loader
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--testbed', dest='testbed')
    args, unknown = parser.parse_known_args()
    
    testbed = loader.load(args.testbed)
    aetest.main(testbed=testbed)