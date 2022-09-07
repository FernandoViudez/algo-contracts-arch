from pyteal import *

most_generous_person = Bytes('most_generous_person')
max_donated = Bytes('max_donated')


def getMostGenerousPerson():
    return Seq(
        Approve()
    )
