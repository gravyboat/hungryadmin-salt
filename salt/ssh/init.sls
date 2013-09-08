ssh:
  pkg:
    - installed
  service:
    - running
    - require:
      - pkg: ssh
    - watch:
      - file: /etc/ssh/ssh_config


/etc/ssh/ssh_config:
  file:
    - managed
    - source: salt://ssh/ssh_config
    - mode: '0644'
    - user: root
    - group: root
    - require:
      - pkg: ssh
