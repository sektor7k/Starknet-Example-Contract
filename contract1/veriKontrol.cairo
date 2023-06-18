#[contract]
mod VeriKontrol {

use starknet::get_caller_address;
use starknet::ContractAddress;


struct Storage {
    my_secret_value_storage:u128,
}

#[view]
fn my_secret_value()->u128{
    my_secret_value_storage::read()
}

#[constructor]
fn constructor(my_secret_value:u128){
    my_secret_value_storage::write(my_secret_value);
}

#[external]
fn claim_points(my_value:u128, my_address:ContractAddress){

    let sender_address = get_caller_address();

    let my_secret_value = my_secret_value_storage::read();

    assert(my_value==my_secret_value,'Yanlis_deger_girdiniz');
    assert(my_address== sender_address,'Yanlis_address_girdiniz');

}

}