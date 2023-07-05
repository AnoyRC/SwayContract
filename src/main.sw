contract;

mod types;
use types::{User, Post, Comment};
use std::storage::storage_vec::*;

abi MyContract {
    #[storage(read, write)]
    fn initialize(name: str[30], img: str[200], desc: str[200], country: str[52], date: u64) -> Result<str[25], str[19]>;

    #[storage(read)]
    fn getUserSelf() -> User;

    #[storage(read)]
    fn getUserByAddress(address : Address) -> User;

    #[storage(read)]
    fn getUserById(id : u64) -> User;

    #[storage(read, write)]
    fn addPost(title: str[100], content: str[1000], date: u64) -> Result<str[12], str[12]>;
}

storage {
    map: StorageMap<Address, u64> = StorageMap {},
    users: StorageMap<u64, User> = StorageMap {},
    posts: StorageMap<u64, Post> = StorageMap {},
    comments: StorageMap<u64, Comment> = StorageMap {},
    id_counter: u64 = 0,
    post_counter: u64 = 0,
    comment_counter: u64 = 0,
}

impl MyContract for Contract {
    #[storage(read, write)]
    fn initialize(name: str[30], img: str[200], desc: str[200], country: str[52], date: u64) -> Result<str[25], str[19]> {
        let sender = msg_sender().unwrap();

        let addr: Address = match sender {
            Identity::Address(identity) => identity,
            _ => revert(0),
        };
        
        let entry = storage.map.get(addr).try_read();

        match entry {
            Some(_) =>  return Err("User already exists"),
            None => {
                let new_id = storage.id_counter.read() + 1;

                let user = User{
                    id: new_id,
                    address: addr,
                    name: name,
                    img: img,
                    desc: desc,
                    country: country,
                    date: date,
                    posts: StorageVec{},
                    following: StorageVec{},
                };

                storage.map.insert(addr, new_id);
                storage.users.insert(new_id, user);

                storage.id_counter.write(new_id);
    
                return Ok("User created successfully");
            }
        }
    }

    #[storage(read)]
    fn getUserSelf() -> User{
        let sender = msg_sender().unwrap();

        let addr: Address = match sender {
            Identity::Address(identity) => identity,
            _ => revert(0),
        };

         let id : u64 = match storage.map.get(addr).try_read(){
            Some(index) => index,
            None => revert(0),
        };

        let entry = storage.users.get(id).try_read();

        match entry {
            Some(user) => {
                return user;
            },
            None => {
                revert(0);
            }
        }
    }

    #[storage(read)]
    fn getUserByAddress(address : Address) -> User{
        let id : u64 = match storage.map.get(address).try_read(){
            Some(index) => index,
            None => revert(0),
        };

        let entry = storage.users.get(id).try_read();

        match entry {
            Some(user) => {
                return user;
            },
            None => {
                revert(0);
            }
        }
    } 

    #[storage(read)]
    fn getUserById(id : u64) -> User{
        let entry = storage.users.get(id).try_read();

        match entry {
            Some(user) => {
                return user;
            },
            None => {
                revert(0);
            }
        }
    }

    #[storage(read, write)]
    fn addPost(title: str[100], content: str[1000], date: u64) -> Result<str[12], str[12]> {
        let sender = msg_sender().unwrap();

        let addr: Address = match sender {
            Identity::Address(identity) => identity,
            _ => revert(0),
        };

        let id : u64 = match storage.map.get(addr).try_read(){
            Some(index) => index,
            None => revert(0),
        };

        let mut entry = storage.users.get(id).try_read();

        match entry {
            Some(user) =>  {

                let new_post_id = storage.post_counter.read() + 1;

                let post = Post{
                    id: new_post_id,
                    user_id: user.id,
                    author: user.name,
                    title: title,
                    content: content,
                    date: date,
                    likes: StorageVec{},
                    comments: StorageVec{},
                };

                let mut posts = user.posts;
                posts.push(new_post_id);

                let user = User{
                    id: user.id,
                    address: user.address,
                    name: user.name,
                    img: user.img,
                    desc: user.desc,
                    country: user.country,
                    date: user.date,
                    posts: posts,
                    following: StorageVec{},
                };

                storage.posts.insert(new_post_id, post);
                storage.users.insert(user.id, user);

                storage.post_counter.write(new_post_id);

                return Ok("Post Created");

            }
            None => {
                return Err("Invalid user");
            }
        }
    }
}
