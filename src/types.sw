library;
use std::storage::storage_vec::*;

pub struct User {
    id : u64,
    address: Address,
    name : str[30],
    img : str[200],
    desc : str[200],
    country : str[52],
    date : u64,
    posts : StorageVec<u64>,
    following : StorageVec<u64>,
}

pub struct Post {
    id : u64,
    user_id : u64,   
    author : str[30],
    title : str[100], 
    date : u64,
    content : str[1000],
    likes : StorageVec<u64>,
    comments : StorageVec<u64>,
}

pub struct Comment {
    id : u64,
    user_id : u64,
    post_id : u64,
    author : str[30],
    date : u64,
    content : str[200],
}

pub enum UserStates {
    UserAlreadyExists: (),
    UserCreatedSuccessfully: (),
}
