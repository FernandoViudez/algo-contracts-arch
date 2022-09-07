from pyteal import *
from pyteal.ast import *


@Subroutine(TealType.none)
def removeFromSale():
    return Approve()
