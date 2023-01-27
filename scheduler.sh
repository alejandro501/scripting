#!/bin/bash

echo "0 6 * * * ./recon/a_recon.sh" | crontab -
crontab -l
echo "Scheduler: a_recon.sh scheduled for every day at 6am"