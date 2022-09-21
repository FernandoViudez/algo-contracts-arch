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
            TxnField.close_remainder_to: winner,
            TxnField.fee: Int(0),
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def solve():
    return Seq(
        Assert(
            And(
                Txn.sender() == App.globalGet(sv_addr),
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
