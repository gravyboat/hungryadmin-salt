# bulkeats environment settings

{% set bulkeats_user = 'bulk' %}
{% set bulkeats_venv = '/home/{0}/bulkeats'.format(bulkeats_user) %}
{% set bulkeats_proj = '{0}/site'.format(bulkeats_venv) %}
{% set bulkeats_theme = '{0}/themes/pelican-themes'.format(bulkeats_proj) %}
{% set bulkeats_url = 'bulkeats.com' %}
{% set bulkeats_root = '{0}/output'.format(bulkeats_proj) %}

bulkeats:
  user: {{ bulkeats_user }}
  venv: {{ bulkeats_venv }}
  proj: {{ bulkeats_proj }}
  theme: {{ bulkeats_theme }}
  url: {{ bulkeats_url }}
  root: {{ bulkeats_root }}
