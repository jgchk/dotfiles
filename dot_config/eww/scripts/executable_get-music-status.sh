#! /bin/bash

playerctl --follow metadata --format '{ "status": "{{status}}", "artist": "{{artist}}", "title": "{{title}}"}' || echo '{"status": ""}'
