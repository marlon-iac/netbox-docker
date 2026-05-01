# Sobre

Esse documento demonstra como utilizar o pyats em conjunto com o netbox

---

# Instalação

1. Crie um ambiente venv

```bash
python3 -m venv .venv
```
2. Instale os requisitos no Ambiente virtual

```bash
source .venv/bin/activate
#atualizar versão pip
python -m pip install --upgrade pip
#instalar pyats
pip install pyats[full]
```

3. Valide a versão instalada

```bash
pyats version check
```

---

# Configuração

1. Defina as variáveis de conectividade com o netbox

```bash
export NETBOX_URL="http://192.168.249.175:8000"
export NETBOX_USER_TOKEN="3QCovwiemJCScq6kk5OSefbJKr4NzEQ2Cr8tufOt" # token v1
export DEF_PYATS_USER="cisco"
export DEF_PYATS_PASS="cisco"
```

2. Faça um teste de conectividade com o netbox

```bash
curl -s -H "Authorization: Token ${NETBOX_USER_TOKEN}" "${NETBOX_URL}/api/dcim/devices/" | python3 -m json.tool | head -50
```

3. Importar o arquivo testbed a partir do netbox

```bash
pyats create testbed netbox \
--output testbed.yaml \
--netbox-url=${NETBOX_URL} \
--user-token=${NETBOX_USER_TOKEN} \
--def_user='%ENV{DEF_PYATS_USER}' \
--def_pass='%ENV{DEF_PYATS_PASS}' \
--url_filter='manufacturer=cisco'
```

---

# Como usar

1. Coleta de comandos no device através do testbed

```bash
genie parse "show version" --testbed-file testbed.yaml
# para executar em um device específico
genie parse "show version" --testbed-file testbed.yaml --device SW1
```

output

```json
{
  "version": {
    "chassis": "IOSv",
    "chassis_sn": "9MFH94WPS25",
    "compiled_by": "sweickge",
    "compiled_date": "Tue 29-Sep-20 11:53",
    "copyright_years": "1986-2020",
    "curr_config_register": "0x101",
    "hostname": "SW1",
    "image_id": "vios_l2-ADVENTERPRISEK9-M",
    "image_type": "developer image",
    "label": "[sweickge-sep24-2020-l2iol-release 135]",
    "last_reload_reason": "Unknown reason",
    "main_mem": "935161",
    "mem_size": {
      "non-volatile configuration": "256"
    },
    "number_of_intfs": {
      "Gigabit Ethernet": "8"
    },
    "os": "IOS",
    "platform": "vios_l2",
    "processor_board_flash": "0K",
    "processor_type": "",
    "returned_to_rom_by": "reload",
    "rom": "Bootstrap program is IOSv",
    "rtr_type": "IOSv",
    "system_image": "flash0:/vios_l2-adventerprisek9-m",
    "uptime": "1 hour, 30 minutes",
    "version": "15.2(20200924:215240)",
    "version_short": "15.2"
  }
}
```

2. Capturar estado de uma configuração

```bash
genie learn "interface" --testbed-file testbed.yaml --output ./before
```

3. Fazer um diff do antes x depois

```bash
# captura novamente o estado do equipamento
genie learn "interface" --testbed-file testbed.yaml --output ./after
# fazer o diff
genie diff ./before ./after
```

---

# Referencia

- [Cisco pyATS → Test Network in SECONDS (+ NetBox Sync)](https://www.youtube.com/watch?v=V_PmWxC2QDA)
- [PyATS + Netbox Integration](https://github.com/network-tocoder/AI-Powered-Network-Automation-Series#video-10-pyats--netbox-integration)
- [pyATS Documentation](https://developer.cisco.com/docs/pyats/)
- [pyATS GitHub](https://github.com/CiscoTestAutomation/pyats)
- [Genie Documentation](https://developer.cisco.com/docs/genie-docs/)
