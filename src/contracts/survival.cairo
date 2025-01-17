#[starknet::contract]
pub mod SurvivalGame {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::Map;
    use core::pedersen::pedersen;
    use crate::types::survival::{Survival, SurvivalStatus};
    use crate::types::events::{SurvivalBegin, NewCorrectAnswer, SurvivalEnd};
    use starknet::storage_access::Store;

    #[storage]
    pub struct Storage {
        pub owner: ContractAddress,
        pub backend_address: ContractAddress,
        pub fee_percentage: u16,
        pub fee_collector: ContractAddress,
        pub survivals: Map<u256, Survival>,
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
    fn create_survival(ref self: ContractState, duration: u64) -> u256 {
        assert(get_caller_address() == self.backend_address.read(), 'UNAUTHORIZED');

        let current_time = starknet::get_block_timestamp();
        let caller = get_caller_address();

        let survival_id = pedersen(current_time.into(), caller.into());

        let new_survival = Survival {
            id: survival_id.into(),
            index: current_time,
            begin_time: current_time,
            end_time: current_time + duration,
            last_correct_address: ContractAddress::zero(),
            total_amount: 0,
            status: SurvivalStatus::ACTIVE,
        };

        self.survivals.write(survival_id.into(), new_survival);

        self
            .emit(
                SurvivalBegin {
                    id: survival_id.into(),
                    begin_time: current_time,
                    end_time: current_time + duration,
                },
            );

        survival_id.into()
    }

    #[external(v0)]
    fn get_survival(self: @ContractState, survival_id: u256) -> Survival {
        self.survivals.read(survival_id)
    }
}
