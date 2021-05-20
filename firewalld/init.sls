
# == State: firewalld
#
# This state installs/runs firewalld.
#
{% from "firewalld/map.jinja" import firewalld with context %}

{% if salt['grains.get']('osfullname') == "SLES" and salt['grains.get']('osmajorrelease')|int < 15 %}

firewalld-unsupported:
  test.show_notification:
    - text: |
        Firewalld is not supported on {{ grains['os'] }}
        See https://www.suse.com/releasenotes/x86_64/SUSE-SLES/15/#fate-323460

{% elif firewalld.enabled %}

include:
  {% if grains['osfinger'] == 'Debian-10' %}
  - firewalld.debian10
  {% endif %}
  - firewalld.config
  - firewalld.ipsets
  - firewalld.backend
  - firewalld.services
  - firewalld.zones
  - firewalld.direct

# iptables service that comes with rhel/centos
iptables:
  service.disabled:
    - enable: False

ip6tables:
  service.disabled:
    - enable: False

package_firewalld:
  pkg.installed:
    - name: {{ firewalld.package }}

service_firewalld:
  service.running:
    - name: {{ firewalld.service }}
    - enable: True         # start on boot
    - require:
      - pkg: package_firewalld
      - file: config_firewalld
      - service: iptables  # ensure it's stopped
      - service: ip6tables # ensure it's stopped

reload_firewalld:
  cmd.wait:
    - name: 'firewall-cmd --reload'
    - require:
      - service: service_firewalld

{% else %}

service_firewalld:
  service.dead:
    - name: {{ firewalld.service }}
    - enable: False # don't start on boot

{% endif %}
