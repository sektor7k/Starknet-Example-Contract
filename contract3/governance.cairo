#[contract]
mod oylama{

    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use array::ArrayTrait;

    trait VoteTrait {
        fn get_voting_result()->(u8, u8);
        fn get_voting_percentage() ->(u8, u8);
    }

    impl VoteTraitImpl of VoteTrait{

        #[inline(always)]
        fn get_voting_result()->(u8, u8){

            let n_yes:u8 = yes_votes::read();
            let n_no:u8 = no_votes::read();

            return(n_yes, n_no);
        }

        #[inline(always)]
        fn get_voting_percentage()->(u8, u8){

            let n_yes:u8 = yes_votes::read();
            let n_no:u8 = no_votes::read();
            
            let t_vote:u8 = n_no + n_yes;

            let p_yes:u8 = (n_yes/t_vote)*100_u8;
            let p_no:u8 = (n_no/t_vote)*100_u8;

            return(p_yes, p_no);
        }
    }


    struct Storage{
        yes_votes: u8,
        no_votes: u8,
        can_vote: LegacyMap<ContractAddress, bool>,
        registered_vote: LegacyMap<ContractAddress, bool>
        
    }

    const YES:u8 = 1_u8;
    const NO:u8 = 0_u8;


    #[event] 
    fn VoteDokum(voter: ContractAddress, vote: u8) {}


    #[constructor]
    fn constructor(voter_1: ContractAddress, voter_2: ContractAddress, voter_3: ContractAddress){
        _register_voters(voter_1, voter_2, voter_3);

        yes_votes::write(0_u8);
        no_votes::write(0_u8);
    }

    #[view]
    fn get_vote_results()->(u8,u8,u8,u8){

        let(n_yes, n_no) = VoteTrait::get_voting_result();
        let(p_yes, p_no) = VoteTrait::get_voting_percentage();

        return (n_yes, n_no, p_yes, p_no);
    }

    #[view]
    fn voter_can_vote(user: ContractAddress)-> bool{
        can_vote::read(user)
    }

    #[view]
    fn voter_registered(user: ContractAddress)-> bool{
        registered_vote::read(user)
    }


    #[external] 
    fn vote(vote:u8){

        assert(vote == NO | vote == YES, 'VOTE_1_OR_0');

        let caller: ContractAddress = get_caller_address();

        assert_allowed(caller);

        can_vote::write(caller, false);

        if (vote == YES){
            yes_votes::write( yes_votes::read() + 1_u8);
        }
        if (vote == NO) {
            no_votes::write( no_votes::read() + 1_u8);
        }

        VoteDokum(caller, vote);
    }

    fn assert_allowed(address: ContractAddress){


        let can_vote:bool = can_vote::read(address);
        let reg_vote: bool = registered_vote::read(address);

        assert(can_vote , 'USER_ALREADY_VOTED');
        assert(reg_vote, 'USER_NOTED_REGISTERED');
    }


    fn _register_voters(voter_1: ContractAddress, voter_2: ContractAddress, voter_3: ContractAddress){
        
        registered_vote::write(voter_1, true);
        can_vote::write(voter_1, true);

        registered_vote::write(voter_2, true);
        can_vote::write(voter_2, true);

        registered_vote::write(voter_3, true);
        can_vote::write(voter_3, true);
    }

}