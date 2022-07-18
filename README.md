# Luau-Math
There are some great lua math libraries on Roblox, such as [MathAddons+](https://devforum.roblox.com/t/mathaddons-useful-functions-all-in-one-place/1836343) which is brilliantly made and geared for someone who paid a lot more attention in math class than I did. This isn't meant to be the most mathtastic math library, it's meant to be the most useful to everyday Roblox dev. It expanded naturally as a result of demand from my own projects. Once Luau was released, along with its support for [custom type checking](https://luau-lang.org/typecheck#type-packs), this library got a makeover and became even more useful since its many APIs could now be provided automatically, alongside relevant input / output information and safeguarding. I'm releasing it publicly today to celebrate my completion of translating the old code to code that passes Luau strict typechecking.

## Features
Even though it's not the most comprehensive library on Roblox, it has some cool features ready to use.
- Strictly typed with exportable custom types
- N-Dimensional Vector and Matrix classes
- More 3D geometry math than you probably need
- N-Dimensional Bezier Curve Solver
- Lerp many things
- N-Dimensional Simplex, Cellular, Voronoi, and Random Noise Generators
- Greedy Mesher

## Goals
This was written with various goals in mind:
- to enhance the existing Roblox / Lua math utility.
- to keep track of useful code relating to shared problems I will likely solve across multiple projects
- to utilize Luau's type checking technology to keep the code easy to use and less prone to issues.
- to be available on wally as a dependency for other math adjacent packages.

## Shorter Term
In the next few weeks I'll likely improve the library in a few ways. 

1. Patches to existing functionality as more people implement this into their projects.
2. Smaller additions to existing functionality based on feedback from other devs.
3. The addition of a new economics sub-library. In an upcoming project I'll be doing a lot of work relating to generating prices, when to change supply, comparitive advantage, faucet / sink calculations, etc. This might branch out to include some basic logistics math, not sure yet.
4. Add some support to the geometry library for basic arcs and parabolas for an upcoming fighting project.

## Longer Term
These are a bit more ambitious, but they're on my wishlist.
1. Physics: Luau support for custom types makes a unit specific kinematics library quite exciting. The dream would be the creation of an alternate modular physics engine that can be use when necessary. Some areas of further expansion include fluid dynamics, thermodynamics, and electromagnetism. Basically, if you have a mechanic that's based off physics, I want the math part to be handled. 
2. Calculus: lot of potential for optimization in game dev. I just got a C in it when I last took a class in it in 2016 so it's taking me a while.
3. Machine Learning: I feel like an AI will likely take my job in the next 30 years, so if there was a time to start supporting neural networks in my projects it'd be sooner rather than later.
4. CSG and Mesh Deformation: I'll be expanding the mesh library rather than making a new one, but the hope is to be able to support math heavy effects like deformable / destroyable / plastic structures. Ideally, without using the Roblox CSG unless they open up a lot more functionality with it + make it runnable on the client side.

## Contributing
If you have some useful code that you want to contribute feel free to let me know or just make a pull request. The only requirement is that it's strictly typed and documented via moonwave. If that's a bit too annoying feel free to make a pull request anyways I can just handle the formatting.

# License