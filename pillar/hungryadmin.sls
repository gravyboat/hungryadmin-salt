# hungryadmin environment settings

{% set hungryadmin_user = 'woody' %}
{% set hungryadmin_venv = '/home/{0}/hungryadmin'.format(hungryadmin_user) %}
{% set hungryadmin_proj = '{0}/site'.format(hungryadmin_venv) %}
{% set hungryadmin_theme = '{0}/themes/pelican-themes'.format(hungryadmin_proj) %}
{% set hungryadmin_plugin = '{0}/plugins/pelican-plugins'.format(hungryadmin_proj) %}
{% set hungryadmin_url = 'hungryadmin.com' %}
{% set hungryadmin_root = '{0}/output'.format(hungryadmin_proj) %}

hungryadmin:
  user: {{ hungryadmin_user }}
  venv: {{ hungryadmin_venv }}
  proj: {{ hungryadmin_proj }}
  theme: {{ hungryadmin_theme }}
  plugin: {{ hungryadmin_plugin }}
  url: {{ hungryadmin_url }}
  root: {{ hungryadmin_root }}
