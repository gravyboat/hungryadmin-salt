# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "letsencrypt/map.jinja" import letsencrypt with context %}

letsencrypt-client-git:
  git.latest:
    - name: https://github.com/letsencrypt/letsencrypt
    - force_reset: True
    - target: {{ letsencrypt.cli_install_dir }}
