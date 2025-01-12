%lang starknet

@external
func say_hello() -> (message: felt):
    return ("Hello, Starknet!")
end
