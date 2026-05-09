#!/usr/bin/env bash
set -o errexit
set -o nounset

cd ../
. ./.venv/bin/activate
ansible-galaxy role install littlegodzillalaboratory.caesar3 --force --roles-path stage/test-examples/roles/
ansible-galaxy collection install geerlingguy.mac --force --collections-path stage/test-examples/collections/
cd examples/

ansible-playbook -i localhost, -c local playbook-direct.yaml
ansible-playbook -i localhost, -c local playbook-import.yaml
