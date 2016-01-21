letsencrypt:
  config: |
    server = https://acme-v01.api.letsencrypt.org/directory
    email = forrest.alvarez@gmail.com
    authenticator = webroot
    webroot-path = {{ salt['pillar.get']('hungryadmin:root') }}
    agree-tos = True
    renew-by-default = True
  domainsets:
    www:
      - {{ salt['pillar.get']('hungryadmin:url') }}
      - www.{{ salt['pillar.get']('hungryadmin:url') }}
