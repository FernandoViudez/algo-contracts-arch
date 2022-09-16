from pyteal import *
from pyteal.ast import *
from modules.oracle_weather.src.bet import *
from modules.oracle_weather.src.solve import *
from modules.oracle_weather.src.creation import *
from modules.oracle_weather.src.begin import *


def handle_event():
    return Seq(
        Cond(
            [Txn.application_args[0] == Bytes('beginBet'), beginBet()],
            [Txn.application_args[0] == Bytes('bet'), bet()],
            [Txn.application_args[0] == Bytes('solve'), solve()],
        ),
        Reject()
    )


def approval() -> Expr:
    return Cond(
        [Txn.application_id() == Int(0), createBet()],
        [Txn.on_completion() == OnComplete.DeleteApplication, Approve()],
        [Txn.on_completion() == OnComplete.UpdateApplication, Approve()],
        [Txn.on_completion() == OnComplete.OptIn, Approve()],
        [Txn.on_completion() == OnComplete.CloseOut, Approve()],
        [Txn.on_completion() == OnComplete.NoOp, handle_event()],
    )


def clear():
    return Approve()
