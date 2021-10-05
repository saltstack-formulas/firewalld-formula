# == State: firewalld.backends
#
# This state ensures that /etc/firewalld/backends/ exists.
#
{% from "./map.jinja" import firewalld with context %}

{% set backend_manage = firewalld.backend.manage %}
{% set backend_pkg = firewalld.backend.pkg %}

# Backward compatibility setting and deprecation notices
### Manage setting (old firewalld:installbackend)
{% if firewalld.installbackend is defined %}
firewalld-installbackend-deprecated:
  test.show_notification:
    - text: |
        'firewalld:installbackend' is deprecated. Set 'firewalld:backend:manage' instead.
        See firewalld/pillar.example for more information

  {% set backend_manage = firewalld.installbackend %}
{% endif %}

### Package setting (old firewalld:backendpackage)
{% if firewalld.backendpackage is defined %}
firewalld-backendpackage-deprecated:
  test.show_notification:
    - text: |
        'firewalld:backendpackage' is deprecated. Use 'firewalld:backend:pkg' instead
        See firewalld/pillar.example for more information

  {% set backend_pkg = firewalld.backendpackage %}
{% endif %}

{%- if backend_manage %}
package_backend:
  pkg.installed:
    - name: {{ backend_pkg }}
{%- endif %}
