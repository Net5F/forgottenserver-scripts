// Original
void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    Player* player = g_game.getPlayerByName(recipient);
    if (!player) {
        player = new Player(nullptr);
        if (!IOLoginData::loadPlayerByName(player, recipient)) {
            return;
        }
    }

    Item* item = Item::CreateItem(itemId);
    if (!item) {
        return;
    }

    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }
}


// This seemed like a simple "match deletes to each new" sort of situation, 
// but turned into something much more complicated.
// It's worth noting, I would normally solve this using smart pointers, to 
// avoid any chance of memory leaks.

// At first, I added deletes appropriately (before returns and at the end 
// of the function). It's possible that this is the intended solution, but 
// the instructions ("assume all method calls work fine") was ambiguous as 
// to whether that includes assumptions about memory ownership. To be safe, 
// I continued on to ask: do loadPlayerByName and internalAddItem take ownership 
// of the pointers passed to them? To know, I had to look at the implementations:

// loadPlayerByName calls loadPlayer, which doesn't seem to take ownership: 
// https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/src/iologindata.cpp#L254
// Thus, it should be our responsibility to delete 'player'.

// internalAddItem is much more confusing: https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/src/game.cpp#L1305
// It seems to have control flow paths where it clearly doesn't do anything with
// the memory, and just returns. In some paths though, it ends up calling a 
// function called ReleaseItem. There's also mention of a reference counter, 
// which is normally related to object lifetime. These both lead us to cleanup:
// https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/src/game.cpp#L4811
// Here, we see more mention of these reference counters. Looking closer, we 
// see that these objects can delete themselves, but only when 
// decrementReferenceCounter is called: https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/src/item.h#L909
// So the question becomes: does our item always end up in a control flow where 
// it has its reference counter incremented and decremented?
// Well, we can see that CreateItem() increments the reference counter: https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/src/item.cpp#L26
// so the question is only whether it reaches ReleaseItem to get decremented.
// Looking again at internalAddItem, it seems that the intent is: in any 
// control flow that returns RETURNVALUE_NOERROR, the memory is handled. Otherwise,
// we need to handle it ourselves.

// If that is the intent, then since the instructions say to assume that all 
// method calls work fine, we can assume the memory is handled and we don't 
// need to delete item. I'm including the code for how to handle the error 
// case though, just to show how it would be done.

// To be honest, I would normally blow this all up and replace it with
// std::shared_ptr since it isn't much code. There wouldn't be any performance
// concerns, since atomic loads and stores (for shared_ptr's reference counter) 
// are basically the same thing as normal loads and stores on x86. Since this is 
// a simple interview question though, I'll leave it here!

// Modified
void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    Player* player = g_game.getPlayerByName(recipient);
    if (!player) {
        player = new Player(nullptr);
        if (!IOLoginData::loadPlayerByName(player, recipient)) {
            delete player;
            return;
        }
    }

    Item* item = Item::CreateItem(itemId);
    if (!item) {
        delete player;
        return;
    }

    // If we fail to add, decrement the reference counter. If nothing else is 
    // referencing the item, it'll delete itself.
    ReturnValue returnValue = g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
    if (returnValue != RETURNVALUE_NOERROR) {
        item->decrementReferenceCounter();
        item = nullptr;
    }

    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }
    
    delete player;
}
