# A Genetic Algorithm to Play Arkanoid (Readme currently being Updated...)

## The Game
Arkanoid is a game for the NES console which was inspired by the original Atari Breakout. It is a slightly complicated version, it involves power ups for paddle or ball(Multi-Ball, PadLengthIncrement, MagneticPad etc). It also includes a variety of enemies in each level and different positioning of blocks. There are also different types of blocks which take multiple hits to destroy.

This game can be played using Neural Networks,Reinforcement Learning etc. Using Genetic Algorithms for this task is difficult due t o the presence of enemy AI and other constraints.

The game is played using an Emulator called FCEUX. Version 2.2.3. After loading up the game, we can run a Lua script through the emulator to take control of the game.

The whole algorithm is coded in Lua in a single file.

## The Algorithm
In every genetic algorithm we find,

A Population, which contains some members(Chromosome/DNA). These chromosomes contains 'genes' which contain information related to the behaviour of that member.

Each member of the population is given a fitness of how well they perform(survive) in that given task/environment. Based on their fitness..............
