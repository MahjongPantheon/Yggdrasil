## Yggdrasil: docker files & configurations to make all pantheon work together

# How to run

Note: on some linux distos almost every docker-related command should be run as root.

1. `make container`
2. `make run`
3. Wait 30-60 sec while postgresql inside container is configuring
4. `cp mimir.conf.php Mimir/config/local/index.php`
5. `cp rheda.conf.php Rheda/config/local/index.php`
7. `make dev` - it will install dependencies for all projects, run migrations 
and will run angular dev server

After that you can send command to create a new event:
```
curl -X POST \
  http://localhost:4001/ \
  -H 'content-type: application/json' \
  -d '{
   "jsonrpc": "2.0",
   "method": "createEvent",
   "params": ["Test offline", "description", "offline", "ema", 90, 1],
   "id": "5db41fc6-5947-423c-a2ca-6e7f7e6a45c0"
}'
```

And access event admin on http://localhost:4002/eid1/ with admin password: `password`

http://localhost:4003/ is angular app where you can enter pin code and set up a game.