{% set hungryadmin_venv = salt['pillar.get']('hungryadmin:venv') %}
{% set hungryadmin_proj = salt['pillar.get']('hungryadmin:proj') %}
{% set hungryadmin_user = salt['pillar.get']('hungryadmin:user') %}

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
    - require:
      - pkg: git
      - virtualenv: hungryadmin_venv
    - watch_in:
      - service: nginx

hungryadmin_pkgs:
  pip:
    - installed
    - bin_env: {{ hungryadmin_venv }}
    - requirements: {{ hungryadmin_proj }}/requirements.txt
    - require:
      - git: hungryadmin
      - pkg: python-pip
      - virtualenv: hungryadmin_venv

/etc/nginx/conf.d/hungryadmin.conf:
  file:
    - managed
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

/etc/nginx/sites-enabled/default:
  file:
    - absent
