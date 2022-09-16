from pyteal import *
from pyteal.ast import *
from modules.oracle_weather.src.creation import *


@Subroutine(TealType.none)
def stackBetIntoServer():
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.Payment,
            TxnField.receiver: Txn.accounts[1],
            TxnField.amount: Int(2000),
            TxnField.fee: Int(0),
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def bet():
    return Seq(
        Assert(
            Or(
                Txn.application_args[1] == Bytes('sunny'),
                # Txn.application_args[1] == Bytes('cloudy'),
                Txn.application_args[1] == Bytes('raining'),
            ),
            App.globalGet(creator_opt) != Txn.application_args[1],

            Gtxn[1].type_enum() == TxnType.Payment,
            Gtxn[1].amount() >= Int(102000),
            Gtxn[1].receiver() == Global.current_application_address(),
            Gtxn[1].sender() != Global.creator_address(),
        ),
        App.globalPut(gambler_addr, Txn.sender()),
        App.globalPut(gambler_money, Minus(Gtxn[1].amount(), Int(2000))),
        App.globalPut(gambler_opt, Txn.application_args[1]),
        stackBetIntoServer(),
        Approve()
    )
