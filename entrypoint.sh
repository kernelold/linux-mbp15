#!/bin/bash
#set -x 
USER=builder
su $USER -c ' '"$*"' ' 
