# Weather bet system
- details
    > bet for the weather of tomorrow's morning (10am) of Argentina, CABA, villa pueyrredon
    > in a bet, two persons can participate, the creator and other random person
    > who wins the bet, gets all the money
    > minimum bet is 0.1 algo's
- process:
    1. call smart contract to create bet (a new smart contract with initial params)
        - initial params must be:
            - tomorrow morning option
                - options are:
                    1. sunny
                    <!-- 2. cloudy -->
                    3. raining
            - money amount to bet
    2. gambler will create an app call to bet for tomorrow's weather sending:
        - weather option
        - money to bet
    3. oracle server will add this bet inside an stack and when this txns reach the date, oracle sever will solve them sending the current weather
    4. if no gamblers, smart contract must be closed by the creator

# technical details
1. on bet sent from other person, smart contract sends a txn that server must read & save into the stack
2. server will do an smart contract call when txn inside the stack reaches the date & hour of the bet
    - server will pass the current weather & smart contract will solve the bet

## Server oracle url:
https://github.com/FernandoViudez/weather-algoracle