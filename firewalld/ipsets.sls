# == State: firewalld.ipsets
#
# This state ensures that /etc/firewalld/ipsets/ exists.
#
{% from "./map.jinja" import firewalld with context %}

# Backward compatibility setting and deprecation notices
{% set ipset_manage = false %}
{% set ipset_pkg = 'ipset' %}
{% set ipset_sets = firewalld.ipsets %}

{% if firewalld.ipset is mapping %}
  {% set ipset_manage = firewalld.ipset.manage %}
  {% set ipset_pkg = firewalld.ipset.pkg %}
{% else %}
### Manage setting (old firewalld:ipset)
firewalld-ipset-deprecated:
  test.show_notification:
    - text: |
        'firewalld:ipset' format has changed and setting it as boolean is deprecated.
        Set 'firewalld:ipset:manage' instead.
        See firewalld/pillar.example for more information

  {% set ipset_manage = firewalld.ipset %}
{% endif %}

### Package setting (old firewalld:ipsetpackage)
{% if firewalld.ipsetpackage is defined %}
firewalld-ipsetpackage-deprecated:
  test.show_notification:
    - text: |
        'firewalld:ipsetpackage' is deprecated. Use 'firewalld:ipset:pkg' instead
        See firewalld/pillar.example for more information

  {% set ipset_pkg = firewalld.ipsetpackage %}
{% endif %}

{%- if ipset_manage %}
package_ipset:
  pkg.installed:
    - name: {{ ipset_pkg }}

directory_firewalld_ipsets:
  file.directory:            # make sure this is a directory
    - name: /etc/firewalld/ipsets
    - user: root
    - group: root
    - mode: 750
    - require:
      - pkg: package_firewalld # make sure package is installed
    - require_in:
      - service: service_firewalld
    - watch_in:
      - cmd: reload_firewalld # reload firewalld config

# == Define: firewalld.ipsets
#
# This defines a ipset configuration, see firewalld.ipset (5) man page.
#
  {% for k, v in ipset_sets.items() %}
  {% set z_name = v.name|default(k) %}

/etc/firewalld/ipsets/{{ z_name }}.xml:
  file.managed:
    - name: /etc/firewalld/ipsets/{{ z_name }}.xml
    - user: root
    - group: root
    - mode: 644
    - source: salt://firewalld/files/ipset.xml
    - template: jinja
    - require:
      - pkg: package_firewalld # make sure package is installed
      - file: directory_firewalld_ipsets
    - require_in:
      - service: service_firewalld
    - watch_in:
      - cmd: reload_firewalld # reload firewalld config
    - context:
        name: {{ z_name }}
        ipset: {{ v|json }}

  {% endfor %}
{%- endif %}
