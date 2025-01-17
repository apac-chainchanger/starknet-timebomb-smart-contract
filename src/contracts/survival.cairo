#[starknet::contract]
pub mod SurvivalGame {
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map,
    };
    use core::starknet::{ContractAddress, get_caller_address, contract_address_const};
    use core::pedersen::pedersen;
    use crate::types::survival::{Survival, SurvivalStatus};
    use crate::types::events::{SurvivalBegin, NewCorrectAnswer, SurvivalEnd};

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        SurvivalBegin: SurvivalBegin,
        NewCorrectAnswer: NewCorrectAnswer,
        SurvivalEnd: SurvivalEnd,
    }

    #[storage]
    pub struct Storage {
        pub owner: ContractAddress,
        pub backend_address: ContractAddress,
        pub fee_percentage: u16,
        pub fee_collector: ContractAddress,
        pub survivals: Map<u256, Survival>,
    }

    #[generate_trait]
    impl StorageImpl of StorageTrait {
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn set_owner(ref self: ContractState, new_owner: ContractAddress) {
            self.owner.write(new_owner);
        }

        fn get_backend_address(self: @ContractState) -> ContractAddress {
            self.backend_address.read()
        }

        fn set_backend_address(ref self: ContractState, new_backend: ContractAddress) {
            self.backend_address.write(new_backend);
        }

        fn get_fee_percentage(self: @ContractState) -> u16 {
            self.fee_percentage.read()
        }

        fn set_fee_percentage(ref self: ContractState, new_percentage: u16) {
            self.fee_percentage.write(new_percentage);
        }

        fn get_fee_collector(self: @ContractState) -> ContractAddress {
            self.fee_collector.read()
        }

        fn set_fee_collector(ref self: ContractState, new_collector: ContractAddress) {
            self.fee_collector.write(new_collector);
        }

        fn get_survival(self: @ContractState, id: u256) -> Survival {
            self.survivals.entry(id).read()
        }

        fn set_survival(ref self: ContractState, id: u256, survival: Survival) {
            self.survivals.entry(id).write(survival);
        }

        fn emit_survival_begin(
            ref self: ContractState, survival_id: u256, begin_time: u64, end_time: u64,
        ) {
            self.emit(SurvivalBegin { id: survival_id, begin_time, end_time });
        }
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
            last_correct_address: contract_address_const::<0>(),
            total_amount: 0,
            status: SurvivalStatus::ACTIVE,
        };

        self.set_survival(survival_id.into(), new_survival);

        self.emit_survival_begin(survival_id.into(), current_time, current_time + duration);

        survival_id.into()
    }

    #[external(v0)]
    fn get_survival(self: @ContractState, survival_id: u256) -> Survival {
        self.get_survival(survival_id)
    }
}
