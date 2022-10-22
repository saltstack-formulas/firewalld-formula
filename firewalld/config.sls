# == State: firewalld._config
#
# This state configures firewalld.
#
{% from "./map.jinja" import firewalld with context %}

directory_firewalld:
  file.directory:            # make sure this is a directory
    - name: /etc/firewalld
    - user: root
    - group: root
    - mode: 750
    - require:
      - pkg: package_firewalld # make sure package is installed

config_firewalld:
  file.managed:
    - name: /etc/firewalld/firewalld.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://firewalld/files/firewalld.conf
    - template: jinja
    - require:
      - pkg: package_firewalld # make sure package is installed
      - file: directory_firewalld
    - require_in:
      - service: service_firewalld
    - watch_in:
      - cmd: reload_firewalld # reload firewalld config
