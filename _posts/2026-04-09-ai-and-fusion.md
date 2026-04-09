---
layout: post
title: AI and Fusion
date: 2026-04-09 13:34 -0700
---
Three months ago, I tried adding MCP support to Autodesk Fusion: [hktonylee/Autodesk-Fusion-360-MCP-Server](https://github.com/hktonylee/Autodesk-Fusion-360-MCP-Server). It worked as an MCP server and could add constraints and solids. However, it still failed on many simple instructions. For example, if you asked it to build a DNA-like helix, it produced a helix but hard-coded all locations (non-parametric). If you asked it to build a hexagon, it did not use the polygon tool and instead hard-coded six lines. In practice, that is not very useful for 3D modeling.

Today, I wanted to revisit that belief. I tried Autodesk's official MCP server, and the experience felt very similar to what I built before. The generated 3D model did not meet the requirement at all; it was not even close.

![]({{ site.image_base }}/2026/04/FusionAndAI.png)

I asked it to create a compliant binary state button. However, the result was not a button at all.

I think it will be a long journey before AI becomes truly useful in 3D modeling. First, the world-model problem needs to be solved. Even after that, we will still need fast simulation to build practical AI CAD systems, because much of 3D modeling is still trial and error.
