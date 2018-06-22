{% from "bulkeats/map.jinja" import bulkeats with context %}

{% set bulkeats_venv = salt['pillar.get']('bulkeats:venv') %}
{% set bulkeats_proj = salt['pillar.get']('bulkeats:proj') %}
{% set bulkeats_user = salt['pillar.get']('bulkeats:user') %}
{% set bulkeats_theme = salt['pillar.get']('bulkeats:theme') %}

include:
  - git
  - nginx
  - python.pip
  - python.virtualenv

install_certbot:
  pkg.installed:
    - name: certbot

{{ bulkeats_user }}:
  user.present:
    - name: {{ bulkeats_user }}
    - shell: /bin/bash
    - home: /home/{{ bulkeats_user }}
    - uid: 2151
    - gid: 2151
    - groups:
      - {{ bulkeats.group }}
    - require:
      - group: {{ bulkeats_user }}
  group.present:
    - gid: 2151

bulkeats_venv:
  virtualenv.managed:
    - name: {{ bulkeats_venv }}
    - user: {{ bulkeats_user }}
    - pip_upgrade: True
    - require:
      - pkg: install_python_virtualenv
      - user: {{ bulkeats_user }}

bulkeats_git:
  git.latest:
    - name: https://github.com/gravyboat/bulkeats.git
    - target: {{ bulkeats_proj }}
    - user: {{ bulkeats_user }}
    - force_reset: True
    - force_clone: True
    - force_checkout: True
    - require:
      - pkg: install_git
      - virtualenv: bulkeats_venv
    - watch_in:
      - service: nginx_service

bulkeats_themes_dir:
  file.directory:
    - name: {{ bulkeats_proj }}/themes
    - user: {{ bulkeats_user }}
    - group: {{ bulkeats_user }}
    - mode: 755

bulkeats_theme:
  git.latest:
    - name: https://github.com/gravyboat/pelican-themes.git
    - target: {{ bulkeats_theme }}
    - user: {{ bulkeats_user }}
    - force_reset: True
    - force_clone: True
    - force_checkout: True
    - require:
      - virtualenv: bulkeats_venv
      - git: bulkeats_git
    - watch_in:
      - service: nginx_service

bulkeats_pkgs:
  pip.installed:
    - bin_env: {{ bulkeats_venv }}
    - requirements: {{ bulkeats_proj }}/requirements.txt
    - user: {{ bulkeats_user }}
    - require:
      - git: bulkeats_git
      - pkg: install_python_pip
      - virtualenv: bulkeats_venv

bulkeats_refresh_pelican:
  cmd.run:
    - runas: {{ bulkeats_user }}
    - name: {{ bulkeats_venv }}/bin/pelican -s {{bulkeats_proj}}/pelicanconf.py
    - require:
      - virtualenv: bulkeats_venv
    - watch:
      - git: bulkeats_git

bulkeats_copy_images:
  cmd.run:
    - name: cp -r {{ bulkeats_proj }}/content/images/ {{ bulkeats_proj }}/output/
    - runas: {{ bulkeats_user }}
    - require:
      - cmd: bulkeats_refresh_pelican


bulkeats_nginx_conf:
  file.managed:
    - name: /etc/nginx/conf.d/bulkeats.conf
    - source: salt://bulkeats/files/bulkeats.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - git: bulkeats_git
      - pkg: install_nginx
    - watch_in:
      - service: nginx_service

bulkeats_site_favicon:
  file.managed:
    - name: {{ salt['pillar.get']('bulkeats:root') }}/favicon.ico
    - source: salt://bulkeats/files/favicon.ico
    - template: jinja
    - user: {{ bulkeats_user }}
    - group: {{ bulkeats_user }}
    - mode: 644
    - require:
      - git: bulkeats_git
      - pkg: install_nginx
    - watch_in:
      - service: nginx_service

bulkeats_ssl_certbot_cron:
  file.managed:
    - name: /etc/cron.d/certbot
    - contents:
      - 0 */12 * * * root test -x /usr/bin/certbot && perl -e 'sleep int(rand(3600))' && certbot renew --cert-name bulkeats.com --webroot -w /home/bulk/bulkeats/site/output; service nginx reload
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: certbot
