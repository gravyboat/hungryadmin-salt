install_nginx:
  pkg.installed:
    - name: nginx

nginx_service:
  service.running:
    - enable: True
    - reload: True

nginx_config:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx_service
