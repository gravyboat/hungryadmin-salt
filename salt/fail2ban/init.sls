fail2ban:
  pkg:
    - installed
  service:
    - running
    - watch:
      - pkg: fail2ban
    - require:
      - pkg: fail2ban
