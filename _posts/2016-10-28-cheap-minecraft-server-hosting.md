---
layout: post
title: Cheap Minecraft Server Hosting
date: 2016-07-18
---

I am still looking for the best way to host a Minecraft server (probably with FTB Infinity Evolved mod). As I mentioned before, DigitalOcean is a really cheap and stable server hosting. Therefore I tested the performance running on DigitalOcean.

My test result is the USD 5 and 10 monthly plan are too slow to run a single player server. You can see overload messages appearing frequently.

    [12:51:57] [Server thread/WARN]: Can't keep up! Did the system time change, or is the server overloaded? Running 6660ms behind, skipping 133 tick(s)
    [12:52:12] [Server thread/WARN]: Can't keep up! Did the system time change, or is the server overloaded? Running 3875ms behind, skipping 77 tick(s)

In game you can see mined blocks reappear and disappear. It is simply unplayable.

However the USD 20 plan can run both official and FTB mods smoothly (for single player). The total CPU usage is around 30-80%. I haven't tested with multiple players. But I estimate that it can support up to 2 players only.

I don't tested with more powerful machines because they are more expansive than the official Minecraft server.

Next time I will test it in EC2 and I hope the result is better due to its finer control.

# Updated 2016-07-18

[Prentice](https://www.flickr.com/photos/echo0101/15655358141) tested a 2~4-player Minecraft server running on EC2 t2.small which consumes 30 CPU credits within 2 hours. So one player consume roughly 5 credits per hour. Since a t2.small produces 12 credits per hour, it can support around  57.6 player-hour in theory. But I guess the machine can support up to 6 players simultaneously.
