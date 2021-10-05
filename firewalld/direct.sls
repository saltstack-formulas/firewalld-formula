# == State: firewalld.direct

{% from "./map.jinja" import firewalld with context %}


# == Define: firewalld.direct
#
# This defines a configuration for permanent direct chains,
# rules and passtthroughs, see firewalld.direct (5) man page.

{%- if firewalld.get('direct', False) %}
/etc/firewalld/direct.xml:
  file:
    - managed
    - name: /etc/firewalld/direct.xml
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://firewalld/files/direct.xml
    - template: jinja
    - require:
      - pkg: package_firewalld # make sure package is installed
      - file: directory_firewalld
    - require_in:
      - service: service_firewalld
    - watch_in:
      - cmd: reload_firewalld # reload firewalld config
    - context:
        direct: {{ firewalld.direct|json }}
{%- endif %}
