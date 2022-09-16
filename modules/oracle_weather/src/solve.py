from re import M
from pyteal import *
from pyteal.ast import *
from modules.oracle_weather.src.creation import *


@Subroutine(TealType.none)
def sendMoneyToWinner(winner: Expr):
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.Payment,
            TxnField.amount: Add(App.globalGet(creator_money), App.globalGet(gambler_money)),
            TxnField.receiver: winner,
            TxnField.fee: Int(0),
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def solve():
    return Seq(
        Assert(
            And(
                Txn.sender() == Addr("5FRCBMIIIY7QIVUUMII5YP536ATXDA472C4KZXSCFLWV7UZZUR2R4K5GOY"),
            )
        ),
        If(
            App.globalGet(creator_opt) == Txn.application_args[1]
        )
        .Then(
            sendMoneyToWinner(Txn.accounts[1])
        )
        .Else(
            sendMoneyToWinner(Txn.accounts[2])
        ),
        Approve()
    )
