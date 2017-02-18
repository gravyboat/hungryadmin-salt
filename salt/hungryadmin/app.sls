{% from "hungryadmin/map.jinja" import hungryadmin with context %}

{% set hungryadmin_venv = salt['pillar.get']('hungryadmin:venv') %}
{% set hungryadmin_proj = salt['pillar.get']('hungryadmin:proj') %}
{% set hungryadmin_user = salt['pillar.get']('hungryadmin:user') %}
{% set hungryadmin_theme = salt['pillar.get']('hungryadmin:theme') %}
{% set hungryadmin_plugin = salt['pillar.get']('hungryadmin:plugin') %}

include:
  - git
  - nginx
  - python.pip
  - python.virtualenv

{{ hungryadmin_user }}:
  user.present:
    - name: {{ hungryadmin_user }}
    - shell: /bin/bash
    - home: /home/{{ hungryadmin_user }}
    - uid: 2150
    - gid: 2150
    - groups:
      - {{ hungryadmin.group }}
    - require:
      - group: {{ hungryadmin_user }}
  group.present:
    - gid: 2150

hungryadmin_venv:
  virtualenv.managed:
    - name: {{ hungryadmin_venv }}
    - user: {{ hungryadmin_user }}
    - pip_upgrade: True
    - require:
      - pkg: install_python_virtualenv
      - user: {{ hungryadmin_user }}

hungryadmin_git:
  git.latest:
    - name: https://github.com/gravyboat/hungryadmin.git
    - target: {{ hungryadmin_proj }}
    - user: {{ hungryadmin_user }}
    - force_reset: True
    - force_clone: True
    - force_checkout: True
    - require:
      - pkg: install_git
      - virtualenv: hungryadmin_venv
    - watch_in:
      - service: nginx_service

hungryadmin_theme:
  git.detached:
    - name: https://github.com/getpelican/pelican-themes.git
    - target: {{ hungryadmin_theme }}
    - user: {{ hungryadmin_user }}
    - ref: be36234f9f7fb4633d7e2eee89833839d7cbf1eb
    - force_clone: True
    - force_checkout: True
    - require:
      - virtualenv: hungryadmin_venv
      - git: hungryadmin_git
    - watch_in:
      - service: nginx_service

hungryadmin_pelican_plugins:
  git.latest:
    - name: https://github.com/getpelican/pelican-plugins.git
    - target: {{ hungryadmin_plugin }}
    - user: {{ hungryadmin_user }}
    - require:
      - pkg: install_git
      - virtualenv: hungryadmin_venv
      - git: hungryadmin_git
    - watch_in:
      - service: nginx_service

hungryadmin_remove_messy_plugins:
  cmd.run:
    - name: find . ! -name 'assets' -type d -exec rm -rf {} +
    - cwd: {{ hungryadmin_plugin }}

hungryadmin_pkgs:
  pip.installed:
    - bin_env: {{ hungryadmin_venv }}
    - requirements: {{ hungryadmin_proj }}/requirements.txt
    - user: {{ hungryadmin_user }}
    - require:
      - git: hungryadmin_git
      - pkg: install_python_pip
      - virtualenv: hungryadmin_venv

refresh_pelican:
  cmd.run:
    - runas: {{ hungryadmin_user }}
    - name: {{ hungryadmin_venv }}/bin/pelican -s {{hungryadmin_proj}}/pelicanconf.py
    - require:
      - virtualenv: hungryadmin_venv
      - cmd: hungryadmin_remove_messy_plugins
    - watch:
      - git: hungryadmin_git

hungryadmin_nginx_conf:
  file.managed:
    - name: /etc/nginx/conf.d/hungryadmin.conf
    - source: salt://hungryadmin/files/hungryadmin.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - git: hungryadmin_git
      - pkg: install_nginx
    - watch_in:
      - service: nginx_service

site_favicon:
  file.managed:
    - name: {{ salt['pillar.get']('hungryadmin:root') }}/favicon.ico
    - source: salt://hungryadmin/files/favicon.ico
    - template: jinja
    - user: {{ hungryadmin_user }}
    - group: {{ hungryadmin_user }}
    - mode: 644
    - require:
      - git: hungryadmin_git
      - pkg: install_nginx
    - watch_in:
      - service: nginx_service

remove_default_sites_enabled:
  file.absent:
    - name: /etc/nginx/sites-enabled/default
    - watch_in:
      - service: nginx_service
