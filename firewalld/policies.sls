# == State: firewalld.policies
#
# This state ensures that /etc/firewalld/policies/ exists.
#
{% from "firewalld/map.jinja" import firewalld with context %}

directory_firewalld_policies:
  file.directory:            # make sure this is a directory
    - name: /etc/firewalld/policies
    - user: root
    - group: root
    - mode: 750
    - require:
      - pkg: package_firewalld # make sure package is installed
    - require_in:
      - service: service_firewalld
    - watch_in:
      - cmd: reload_firewalld # reload firewalld config

# == Define: firewalld.policies
#
# This defines a policy configuration, see firewalld.policy (5) man page.
#
{% for k, v in salt['pillar.get']('firewalld:policies', {}).items() %}
{% set z_name = v.name|default(k) %}

/etc/firewalld/policies/{{ z_name }}.xml:
  file.managed:
    - name: /etc/firewalld/policies/{{ z_name }}.xml
    - user: root
    - group: root
    - mode: 644
    - source: salt://firewalld/files/policy.xml
    - template: jinja
    - require:
      - pkg: package_firewalld # make sure package is installed
      - file: directory_firewalld_policies
    - require_in:
      - service: service_firewalld
    - watch_in:
      - cmd: reload_firewalld # reload firewalld config
    - context:
        name: {{ z_name }}
        policy: {{ v|json }}

{% endfor %}
