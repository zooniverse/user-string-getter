# zooniverse-user-string-getter
Code used by [Geordi](https://github.com/zooniverse/geordi) to get current zooniverse user ID in a consistent string format, or "(anonymous)" for non-logged in users.

The string returned might look like any of these:
* `"1231412"` (Ouroboros-style ID)
* `"panoptes-123144"` (Panoptes-style ID)
* `"(anonymous)"` (no user logged in)

The last one is what will be returned as a fallback if the module is unable to determine Zooniverse User ID or IP address.
Note that the Geordi server can be used to determine the clientIP for each anonymous user.

# If you need the IP as well
This module used to provide the IP when it could, in place of `"(anonymous)"`, but this capability has been deprecated as Geordi handles this now.
If you don't want to use Geordi to get the IP, but you still want to use this module and you need the IP as part of the string, please use version 1.1.4, which can be obtained by extracting a specific commit `c226a5dd145f14320dca0e95840a11de6e858691`, which can be done using the following commands:
```
git clone https://github.com/zooniverse/user-string-getter
cd user-string-getter
git clone c226a5d
```

The following instructions are for the latest version 1.1.22, which no longer does any IP lookup.

# How to use
First, install the module to your project:

```
npm install --save zooniverse-user-string-getter
```

Now, in your `app/index.coffee` file (for hem projects), or your primary index file for other JavaScript projects, set up the library as in this CoffeeScript example:
```
# import any needed libraries
User = require 'zooniverse/lib/models/user'

# import the class
ZooUserStringGetter = require 'zooniverse-user-string-getter'

# define a callback function for retrieving Zooniverse User IDs
checkZooUserID = ->
  User.current?.zooniverse_id

# set up the Getter, passing in the callback function and any parameter the callback function needs (none in this case)
UserStringGetter = new ZooUserStringGetter(checkZooUserID,null)
```

Now you can use the library in your JavaScript/CoffeeScript layer, as in this CoffeeScript example:
As shown here, you can use the `currentUserID` variable within the user string getter to store your last retrieved result, to avoid re-fetching it multiple times.
If set to anything other than null, the user string getter will used the cached value instead of recalculating the string.

```
UserStringGetter.getUserID()
.then (data) =>
  if data?
    UserStringGetter.currentUserID = data
.fail =>
  UserStringGetter.currentUserID = "(anonymous)"
.always =>
  userID = UserStringGetter.currentUserID
  # do something with the retrieved user ID
  
```

## An important note about synchronicity 
Note that the user string getter is asynchronous. Its `getUserID()` method returns a [jQuery `Promise` object](http://api.jquery.com/Types/#Promise), and as such you can chain events onto the end of the retrieval call. This is a historical leftover because this library used to use an external web service over AJAX to retrieve the IP. You need to wait for the code to complete before you can use the result, in other words make sure you put any code that depends on the result into your `always` block.
This may require you to do some restructuring of your code. See the [zooniverse-geordi-client code](https://github.com/zooniverse/geordi-client/blob/master/src/geordi-client.coffee#L137) for an example of how to properly chain your AJAX calls to deal with the result.
