base:
  'hungryadminprod2':
    - nginx
    - nginx.ramdisk
    - fail2ban
    - ssh
    - letsencrypt.install
    - letsencrypt.config
    - letsencrypt.domains
    - hungryadmin.app
