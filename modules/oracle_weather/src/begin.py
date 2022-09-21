from pyteal import *
from pyteal.ast import *
from modules.oracle_weather.src.creation import *


@Subroutine(TealType.none)
def beginBet():
    return Seq(
        Assert(
            And(
                Txn.sender() == Global.creator_address(),
                Or(
                    Txn.application_args[1] == Bytes('sunny'),
                    # Txn.application_args[1] == Bytes('cloudy'),
                    Txn.application_args[1] == Bytes('raining'),
                ),
                Gtxn[1].type_enum() == TxnType.Payment,
                # 0.2 algos, 0.1 for betting and 0.1 for minimum balance
                Gtxn[1].amount() >= Int(200000),
                Gtxn[1].receiver() == Global.current_application_address(),
                Gtxn[1].sender() == Global.creator_address(),
                # Int(Txn.application_args[2]) >= "now + 1day"
            ),
        ),
        App.globalPut(creator_money, Minus(Gtxn[1].amount(), Int(100000))),
        App.globalPut(creator_opt, Txn.application_args[1]),
        App.globalPut(bet_timestamp_date, Btoi(Txn.application_args[2])),
        Approve()
    )
