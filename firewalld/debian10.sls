{% from "./map.jinja" import firewalld with context %}

firewalld_repo_buster-backports:
  pkgrepo.managed:
    - name: deb http://deb.debian.org/debian buster-backports main
    - file: /etc/apt/sources.list.d/buster-backports.list

firewalld_install_iptables_from_buster-backports:
  pkg.installed:
    - name: iptables
    - fromrepo: buster-backports
    - version: '1.8.5*'
    - refresh: True
