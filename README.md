# zooniverse-user-string-getter
Code used by [Geordi](https://github.com/zooniverse/geordi) to get current zooniverse user ID or, for anonymous users, the IP address.

The string returned might look like any of these:
* `"1231412"`
* `"panoptes-123144"`
* `"(123.233.124.44)"`
* `"(site.somedomain.com [12.54.223.55])"`
* `"(anonymous)"`

The last one is what will be returned as a fallback if the module is unable to determine Zooniverse User ID or IP address.

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

# set up the Getter, passing in the callback function
UserStringGetter = new ZooUserStringGetter(checkZooUserID)
```

Now you can use the library in your JavaScript/CoffeeScript layer, as in this CoffeeScript example:
As shown here, you can use the `currentUserID` variable within the user string getter to store your last retrieved result, to avoid refetching it multiple times.
If set to anything other than null, the user string getter will used the cached value instead of recalculating the string.

```
UserStringGetter.getUserIDorIPAddress()
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
Note that the user string getter is asynchronous. Its `getUserIDorIPAddress()` method returns a [jQuery `Promise` object](http://api.jquery.com/Types/#Promise), and as such you can chain events onto the end of the retrieval call. This is done because the library uses an external web service over AJAX to retrieve the IP, and as such, you need to wait for the code to complete before you can use the result.
This may require you to do some restructuring of your code. See the [zooniverse-geordi-client code](https://github.com/zooniverse/geordi-client/blob/master/src/index.coffee#L113) for an example of how to properly chain your AJAX calls to deal with the result.
