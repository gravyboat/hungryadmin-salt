install_fail2ban:
  pkg.installed:
    - name: fail2ban

fail2ban_service:
  service.running:
    - name: fail2ban
    - watch:
      - pkg: install_fail2ban
    - require:
      - pkg: install_fail2ban
