#!/bin/bash

echo "0 6 * * * ./recon/a_recon.sh" | crontab -
crontab -l
color_me magenta "Scheduler: a_recon.sh scheduled for every day at 6am"