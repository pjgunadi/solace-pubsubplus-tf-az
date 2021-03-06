version: '3.9'
services:
  vmr:
    container_name: ${container_name}
    hostname: ${container_name}
    image: solace/solace-pubsub-standard:latest
    shm_size: 1g
    ulimits:
      core: 1
      nofile:
        soft: 2448
        hard: 6592
    deploy:
      restart_policy:
        condition: on-failure
        max_attempts: 1
    volumes:
      - jail:/usr/sw/jail
      - diags:/var/lib/solace/diags
      - spool:/usr/sw/internalSpool
      - adbbkp:/usr/sw/adb
      - adb:/usr/sw/internalSpool/softAdb
      - var:/usr/sw/var
    ports:
    #Port Mappings:  Ports are mapped straight through from host to
    #container.  This may result in port collisions on commonly used
    #ports that will cause failure of the container to start.
      #Web transport
      - '8008:8008'
      #Web transport over TLS
      #- '1443:1443'
      #SEMP over TLS
      #- '1943:1943'
      #MQTT Default VPN
      - '1883:1883'
      #AMQP Default VPN over TLS
      #- '5671:5671'
      #AMQP Default VPN
      - '5672:5672'
      #MQTT Default VPN over WebSockets
      - '8000:8000'
      #MQTT Default VPN over WebSockets / TLS
      #- '8443:8443'
      #MQTT Default VPN over TLS
      #- '8883:8883'
      #SEMP / PubSub+ Manager
      - '8080:8080'
      #REST Default VPN
      - '9000:9000'
      #REST Default VPN over TLS
      #- '9443:9443'
      #SMF
      - '55555:55555'
      #SMF Compressed
      - '55003:55003'
      #SMF over TLS
      #- '55443:55443'
      #SSH connection to CLI
      - '2222:2222'
    environment:
      - username_admin_globalaccesslevel=${vmr_user}
      - username_admin_password=${vmr_password}
      - system_scaling_maxconnectioncount=${max_connection}

volumes:
  jail:
  diags:
  spool:
  adbbkp:
  adb:
  var:
