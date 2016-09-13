# == State: firewalld.services
#
# This state ensures that /etc/firewalld/services/ exists.
#
{% from "firewalld/map.jinja" import firewalld with context %}

directory_firewalld_services:
  file.directory:            # make sure this is a directory
    - name: /etc/firewalld/services
    - user: root
    - group: root
    - mode: 750
    - require:
      - pkg: package_firewalld # make sure package is installed
    - listen_in:
      - module: service_firewalld # restart service


# == Define: firewalld.services
#
# This defines a service configuration, see firewalld.service (5) man page.
# You usually don't need this, you can simply add ports to zone.

{% for k, v in salt['pillar.get']('firewalld:services', {}).items() %}
{% set s_name = v.name|default(k) %}

/etc/firewalld/services/{{ s_name }}.xml:
  file:
    - managed
    - name: /etc/firewalld/services/{{ s_name }}.xml
    - user: root
    - group: root
    - mode: 644
    - source: salt://firewalld/files/service.xml
    - template: jinja
    - require:
      - pkg: package_firewalld # make sure package is installed
      - file: directory_firewalld_services
    - listen_in: 
      - module: service_firewalld # restart service
    - context:
        name: {{ s_name }}
        service: {{ v|json }}

{% endfor %}
