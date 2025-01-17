use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct SurvivalBegin {
    #[key]
    pub id: u256,
    pub begin_time: u64,
    pub end_time: u64,
}

#[derive(Drop, starknet::Event)]
pub struct NewCorrectAnswer {
    #[key]
    pub survival_id: u256,
    pub solver: ContractAddress,
    pub amount: u64,
}

#[derive(Drop, starknet::Event)]
pub struct SurvivalEnd {
    #[key]
    pub survival_id: u256,
    pub winner: ContractAddress,
    pub total_amount: u64,
}
