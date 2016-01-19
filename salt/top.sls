base:
  'hungryadminprod2':
    - nginx
    - fail2ban
    - ssh
    - letsencrypt.install
    - letsencrypt.config
    - letsencrypt.domains
    - hungryadmin.app
