#!/bin/bash

# Ativar VNC no Raspberry Pi
sudo raspi-config nonint do_vnc 0

# Habilitar e iniciar serviço VNC
sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced.service

# Mostrar status
sudo systemctl status vncserver-x11-serviced.service --no-pager
