from pyteal import *
from pyteal.ast import *
from modules.donate.src.generous_person import max_donated, most_generous_person


def donate():
    return Seq(
        [
            # Follow, implement & understand algorand guidelines checks
            If(
                And(
                    Global.group_size() == Int(2),
                    Gtxn[1].type_enum() == TxnType.Payment,
                    Gtxn[1].receiver() == Global.current_application_address(),
                    Gtxn[1].amount() > Int(0),
                    App.globalGet(max_donated) < Gtxn[1].amount()
                ),
                Seq([
                    App.globalPut(max_donated, Gtxn[1].amount()),
                    App.globalPut(most_generous_person, Txn.sender())
                ]),
                Return(Int(0))
            ),
            Return(Int(1))
        ]
    )
