{% set hungryadmin_venv = salt['pillar.get']('hungryadmin:venv') %}
{% set hungryadmin_proj = salt['pillar.get']('hungryadmin:proj') %}
{% set hungryadmin_user = salt['pillar.get']('hungryadmin:user') %}
{% set hungryadmin_theme = salt['pillar.get']('hungryadmin:theme') %}

include:
  - git
  - nginx
  - python.pip
  - python.virtualenv

{{ hungryadmin_user }}:
  user:
    - present
    - shell: /bin/bash
    - home: /home/{{ hungryadmin_user }}
    - uid: 2150
    - gid: 2150
    - groups:
      - sudo
    - require:
      - group: {{ hungryadmin_user }}
  group:
    - present
    - gid: 2150

hungryadmin_venv:
  virtualenv:
    - managed
    - name: {{ hungryadmin_venv }}
    - runas: {{ hungryadmin_user }}
    - require:
      - pkg: python-virtualenv
      - user: {{ hungryadmin_user }}

hungryadmin:
  git:
    - latest
    - name: https://github.com/gravyboat/hungryadmin.git
    - target: {{ hungryadmin_proj }}
    - runas: {{ hungryadmin_user }}
    - force: True
    - force_checkout: True
    - require:
      - pkg: git
      - virtualenv: hungryadmin_venv
    - watch_in:
      - service: nginx

refresh_pelican:
  cmd:
    - run
    - user: {{ hungryadmin_user }}
    - name: {{ hungryadmin_venv }}/bin/pelican -s {{hungryadmin_proj}}/pelicanconf.py
    - require:
      - virtualenv: hungryadmin_venv
    - watch:
      - git: hungryadmin

hungryadmin_theme:
  git:
    - latest
    - name: https://github.com/gravyboat/pelican-bootstrap3.git
    - target: {{ hungryadmin_theme }}
    - runas: {{ hungryadmin_user }}
    - force: True
    - force_checkout: True
    - require:
      - virtualenv: hungryadmin_venv
      - git: hungryadmin
    - watch_in:
      - service: nginx


hungryadmin_pkgs:
  pip:
    - installed
    - bin_env: {{ hungryadmin_venv }}
    - requirements: {{ hungryadmin_proj }}/requirements.txt
    - runas: {{ hungryadmin_user }}
    - require:
      - git: hungryadmin
      - pkg: python-pip
      - virtualenv: hungryadmin_venv

hungryadmin_nginx_conf:
  file:
    - managed
    - name: /etc/nginx/conf.d/hungryadmin.conf
    - source: salt://hungryadmin/files/hungryadmin.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - git: hungryadmin
      - pkg: nginx
    - watch_in:
      - service: nginx

site_favicon:
  file:
    - managed
    - name: {{ hungryadmin_proj }}/favicon.ico
    - source: salt://hungryadmin/files/favicon.ico
    - template: jinja
    - user: {{ hungryadmin_user }}
    - group: {{ hungryadmin_user }}
    - mode: 644
    - require:
      - git: hungryadmin
      - pkg: nginx
    - watch_in:
      - service: nginx

/etc/nginx/sites-enabled/default:
  file:
    - absent
