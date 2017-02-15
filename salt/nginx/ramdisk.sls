include:
  - nginx


nginx_cache:
  mount.mounted:
    - name:    /var/cache/nginx
    - device:  tmpfs
    - fstype:  tmpfs
    - opts:    defaults,size=64M
    - persist: True
    - mkmnt:   True
    - watch_in:
      - service: nginx_service


