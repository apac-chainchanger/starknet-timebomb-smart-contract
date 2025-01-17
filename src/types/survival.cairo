use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
pub struct Survival {
    pub id: u256,
    pub index: u64,
    pub begin_time: u64,
    pub end_time: u64,
    pub last_correct_address: ContractAddress,
    pub total_amount: u256,
    pub status: u8,
}

pub mod SurvivalStatus {
    pub const ACTIVE: u8 = 0;
    pub const INACTIVE: u8 = 1;
    pub const PAID: u8 = 2;
}
