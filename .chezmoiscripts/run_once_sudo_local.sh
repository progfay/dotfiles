#!/bin/sh

# https://gist.github.com/farhaduneci/10e30162eceb12a87bcee92b247b8808
sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local > /dev/null
