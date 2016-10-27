---
layout: post
title: Arrow Function v.s. this in Google Chrome
---

When I was debugging some strange error message in a React Native project, I am puzzled by an incorrect `this` problem. Here is the code snippet:

``` javascript
class MainWindow extends Components<{}, {}> {
    componentDidMount() {
        someSubject.subscribe(page => {
            this.setState({currentPage: page});     // Wrong `this` here
        });
    }
}
```

Below is the caller of the above code.

``` javascript
SafeSubscriber.prototype.__tryOrSetError = function (parent, fn, value) {
    // ...

    fn.call(this._context, value);      // Where the callback is called
    
    // ...
};
```

Whenever the inner function is called, the `this` refers to `SafeSubscriber` which is incorrect.

I checked this with Google Chrome debugger as shown below:

![Google Chrome Debug]({{ site.image_base }}/2016/10/27/ChromeDebug.png){: .center }

It is well-known that in newest ECMAScript version, the arrow function captures `this` in lexical scope. So the `this` should capture `MainWindow` instead of `SafeSubscriber`.

So far I had not realized that this was the problem of Chrome. I still googled it for the solution. And Google returned me some bug report in React Native ([Link 1](https://github.com/babel/babel/issues/4162), [Link 2](http://stackoverflow.com/questions/37449580/this-is-no-longer-bound-when-using-arrow-functions-after-upgrading-to-react-nati/37474298#37474298)). I then spent an hour to further dig into the problem.

Suddenly I checked the packed source of the site.

![Site Source]({{ site.image_base }}/2016/10/27/RawCode.png){: .center }

And I guessed that the debugger in Google Chrome may not translate `this` into `_this2`. I tested my assumption and it really shocks me.

![The Truth]({{ site.image_base }}/2016/10/27/TrueThis.png){: .center }

Lesson learnt. Everything can go wrong. **And don't rely too much on browser when developing transpiled languages like ES2015.**
