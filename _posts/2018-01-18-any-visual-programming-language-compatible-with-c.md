---
layout: post
title: Any visual programming language compatible with C?
---
I wish I could find some visual programming language that can compile to C-compatible object file / binary. So that I can use that language as a glue language for non-professional programmers. For example, researchers can use it to modify and run a numerical computation engine. Python is already good but visual language is better in terms of usability and abstraction level. VP is also better when developing a network with thousands of interdependent variables. If it could perform comparable to Rust or Go in terms of speed and memory usage it would be fantastic.

JetBrains MPS seems to be a good solution but it has very steep learning curve. And it is too generic which provides too many unnecessary things.

I did some research and could not find any better. So naturally I imagine if I could create one myself.

What I have in my mind is to define some intermediate language that is subset of C (may use a lot of comment). So that anyone can easily delete the comment and fall back to normal C. Because it is C so it can surely emit C-compatible object file. I also hope that the runtime of the language is minimal and easily replaceable (i.e. bare-metal environment). For example game engine may use their own event loop implementation.

Another project is to make a IDE that can manipulate the intermediate language graphically. It will have a good UI/UX designed for both beginners and professionals. It can also read symbols defined in other header files as to coorperate with other components. But this will be another topic.

Can anyone advise some starting tips or difficulties in implementing this language. Or if you feel this is impossible just let me know.
