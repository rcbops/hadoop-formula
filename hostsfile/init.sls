# Handpicked from https://github.com/saltstack-formulas/hostsfile-formula
# populate /etc/hosts with names and IP entries from your salt cluster
# the minion id has to be the fqdn for this to work

{%- set fqdn = grains['id'] %}

# Clean hosts file
{% set ips = salt['network.ipaddrs']() %}
{% for ip in ips %}
clean-{{ ip }}:
  host.absent:
    - ip: {{ ip }}
    - names:
      - {{ fqdn }}
{% endfor %}

{%- set intface = salt['pillar.get']('interfaces:private', 'eth0') %}
{%- set all_interfaces = salt['mine.get']('*', 'network.interfaces') %}
{%- set addrs = {} %}
{%- for name, interfaces in all_interfaces.items() %}
{% set ip = [interfaces[intface]['inet'][0]['address']] %}
{% do addrs.update({name: ip}) %}
{% endfor %}

{%- if addrs is defined %}
{%- set if = grains['maintain_hostsfile_interface'] %}

{%- for name, addrlist in addrs.items() %}
{{ name }}-host-entry:
  host.present:
    - ip: {{ addrlist|first() }}
    - names:
      - {{ name }}
{% endfor %}

{% endif %}

