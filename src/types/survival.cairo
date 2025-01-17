use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
struct Survival {
    id: u256,
    index: u256,
    begin_time: u64,
    end_time: u64,
    last_correct_address: ContractAddress,
    total_amount: u256,
    status: u8,
}

mod SurvivalStatus {
    const ACTIVE: u8 = 0;
    const INACTIVE: u8 = 1;
    const PAID: u8 = 2;
}

#[derive(Drop, Serde)]
struct SurvivalPage {
    survivals: Array<Survival>,
    total_count: u256,
    has_next: bool,
}
