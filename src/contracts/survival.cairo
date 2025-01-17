#[starknet::contract]
mod survival_game {
    use starknet::ContractAddress;
    use super::super::types::survival::{Survival, SurvivalStatus};
    use super::super::types::events::{SurvivalBegin, NewCorrectAnswer, SurvivalEnd};

    #[storage]
    struct Storage {
        owner: ContractAddress,
        backend_address: ContractAddress,
        fee_percentage: u16,
        fee_collector: ContractAddress,
        survivals: LegacyMap<u256, Survival>,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        backend_address: ContractAddress,
        fee_collector: ContractAddress,
        fee_percentage: u16,
    ) {
        self.owner.write(owner);
        self.backend_address.write(backend_address);
        self.fee_collector.write(fee_collector);
        self.fee_percentage.write(fee_percentage);
    }

    #[external(v0)]
    fn create_survival(
        ref self: ContractState,
        duration: u64,
    ) -> u256 {
        assert(get_caller_address() == self.backend_address.read(), 'UNAUTHORIZED');

        let current_time = starknet::get_block_timestamp();
        let caller = get_caller_address();

        let survival_id = pedersen::pedersen(current_time, caller);

        let new_survival = Survival {
            id: survival_id,
            index: current_time,
            begin_time: current_time,
            end_time: current_time + duration,
            last_correct_address: ContractAddress::default(),
            total_amount: 0,
            status: SurvivalStatus::ACTIVE,
        };

        self.survivals.write(survival_id, new_survival);

        self.emit(SurvivalBegin {
            id: survival_id,
            begin_time: current_time,
            end_time: current_time + duration,
        });

        survival_id
    }

    #[view]
    fn get_survival(
        self: @ContractState,
        survival_id: u256,
    ) -> Survival {
        self.survivals.read(survival_id)
    }
}
