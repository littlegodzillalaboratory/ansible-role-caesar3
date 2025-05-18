<img align="right" src="https://raw.github.com/cliffano/ansible-role-caesar3/main/avatar.jpg" alt="Avatar"/>

[![Build Status](https://github.com/cliffano/ansible-role-caesar3/workflows/CI/badge.svg)](https://github.com/cliffano/ansible-role-caesar3/actions?query=workflow%3ACI)
[![Security Status](https://snyk.io/test/github/cliffano/ansible-role-caesar3/badge.svg)](https://snyk.io/test/github/cliffano/ansible-role-caesar3)
<br/>

Ansible Role Caesar III
-----------------------

Ansible Role Caesar III is a Ansible role for provisioning Caesar III city-building game .

Usage
-----

Use the role in your playbook:

    - hosts: all

      vars:
        ans_reverse: true
        ans_transformation: 'upper'

      roles:
        - cliffano.ansible-role-caesar3