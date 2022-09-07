python -c "import algosdk.encoding as e; print(e.encode_address(e.checksum(b'appID'+($1).to_bytes(8, 'big'))))"
