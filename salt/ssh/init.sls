ssh:
  pkg:
    - installed
  service:
    - running
    - require:
      - pkg: ssh
    - watch:
      - file: /etc/ssh/sshd_config


/etc/ssh/sshd_config:
  file:
    - managed
    - source: salt://ssh/sshd_config
    - mode: '0644'
    - user: root
    - group: root
    - require:
      - pkg: ssh
