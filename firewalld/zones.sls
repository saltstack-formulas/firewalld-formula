# == State: firewalld.zones
#
# This state ensures that /etc/firewalld/zones/ exists.
#
{% from "./map.jinja" import firewalld with context %}

directory_firewalld_zones:
  file.directory:            # make sure this is a directory
    - name: /etc/firewalld/zones
    - user: root
    - group: root
    - mode: 750
    - require:
      - pkg: package_firewalld # make sure package is installed
    - require_in:
      - service: service_firewalld
    - watch_in:
      - cmd: reload_firewalld # reload firewalld config

# == Define: firewalld.zones
#
# This defines a zone configuration, see firewalld.zone (5) man page.
#
{% for k, v in salt['pillar.get']('firewalld:zones', {}).items() %}
{% set z_name = v.name|default(k) %}

/etc/firewalld/zones/{{ z_name }}.xml:
  file.managed:
    - name: /etc/firewalld/zones/{{ z_name }}.xml
    - user: root
    - group: root
    - mode: 644
    - source: salt://firewalld/files/zone.xml
    - template: jinja
    - require:
      - pkg: package_firewalld # make sure package is installed
      - file: directory_firewalld_zones
    - require_in:
      - service: service_firewalld
    - watch_in:
      - cmd: reload_firewalld # reload firewalld config
    - context:
        name: {{ z_name }}
        zone: {{ v|json }}

{% endfor %}
