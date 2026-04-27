PLUGINS = [
    "netbox_diode_plugin",
]

PLUGINS_CONFIG = {
    "netbox_diode_plugin": {
        "diode_target_override": "grpc://<hostname_diode>:<port>/diode",
        "diode_username": "diode",
        "client_id": "<YOUR_CLIENT_ID>",
        "netbox_to_diode_client_secret": "<YOUR_CLIENT_SECRET>"
    },
}