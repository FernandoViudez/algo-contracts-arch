# Smart contracts

## Project structure

1. Each smart contract represents a single module
2. each smart contract module must have:
    - ABI implementation for smart contract interface
    - README.md with smart contract specific functionality
    - /src
        - python code for the smart contract 
        - each python code should be a method
        - index.py must call all methods and handle call events.

## Steps before using smart contracts

1. clone Algorand sandbox
2. open docker-desktop (install if you don't have it)
3. go to this current dir
4. you MUST bind build folder with docker container. Below "ports" inside algod service at "docker-compose.yml" file add:
`
volumes:
      - type: bind
        source: (here goes your path to build folder)
        target: /data
` 
5. execute ./sandbox up <config-name> ~> config name can be found in algorand sandbox config files

### Possible config names
- beta
- betanet
- dev
- devnet
- mainnet
- testnet

## How to use sh's
1. ./build.sh
    - when you coded your smart contract, then execute ./build.sh modules.<contract-folder-name>.index
    example: ./build.sh donation
    
2. ./creation.sh <first-arg*> <second-arg?> <third-arg?>
    - receives three arguments: 
        1. the name of the module (smart contract module)
        2. if custom creation or not. If it is, then: 
            - set "custom" as arg value
            - if no custom, the set "default" or leave empty.
            - note: custom-creation.sh file MUST have implementation to save APP_ID and deploy the app.
        3. indicates if only run the smart contract, if it is, then a 4th arg is required (app-id to run)
            - if no custom, the set "default". DO NOT leave empty.
            - to run (no build, simply execute smart contract index.sh) add "run" as third arg value
    - remember to update init.sh with your creator address
    - this sh will execute the execute.sh script at ./build/core inside docker algod service container
    - this script will source config.sh file of your current SC module, this file must have all your required variables to call index.sh. (Note that app_id & app_addr are already available from sm.sh in core folder, you can use this vars in your atomic.sh)