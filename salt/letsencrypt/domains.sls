# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "letsencrypt/map.jinja" import letsencrypt with context %}

{% for setname, domainlist in salt['pillar.get']('letsencrypt:domainsets').items() %}
create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}:
  cmd.run:
    - unless: >
        test -f /etc/letsencrypt/{{
          domainlist | join('.check && test -f /etc/letsencrypt/')
        }}.check
    - name: {{
          letsencrypt.cli_install_dir
        }}/letsencrypt-auto -d {{ domainlist|join(' -d ') }} certonly
    - cwd: {{ letsencrypt.cli_install_dir }}
    - require:
      - file: letsencrypt-config

{% for domain in domainlist %}
touch /etc/letsencrypt/{{ domain }}.check:
  file.touch:
    - name: /etc/letsencrypt/{{ domain }}.check
    - unless: test -f /etc/letsencrypt/{{ domain }}.check
    - require:
      - cmd: create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}
{% endfor %}

letsencrypt-crontab-{{ setname }}-{{ domainlist[0] }}:
  cron.present:
    - name: {{
          letsencrypt.cli_install_dir
        }}/letsencrypt-auto -d {{ domainlist|join(' -d ') }} certonly && service nginx reload
    - month: '*/2'
    - minute: random
    - hour: random
    - daymonth: random
    - identifier: letsencrypt-{{ setname }}-{{ domainlist[0] }}
    - require:
      - cmd: create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}

{% endfor %}
