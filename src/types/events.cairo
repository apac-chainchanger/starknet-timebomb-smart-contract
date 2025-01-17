use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
struct SurvivalBegin {
    id: u256,
    begin_time: u64,
    end_time: u64,
}

#[derive(Drop, starknet::Event)]
struct NewCorrectAnswer {
    survival_id: u256,
    solver: ContractAddress,
    amount: u256,
}

#[derive(Drop, starknet::Event)]
struct SurvivalEnd {
    survival_id: u256,
    winner: ContractAddress,
    total_amount: u256,
}
