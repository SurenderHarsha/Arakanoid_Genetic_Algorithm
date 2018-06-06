# A Genetic Algorithm to Play Arkanoid (Readme currently being Updated...)

## The Game
Arkanoid is a game for the NES console which was inspired by the original Atari Breakout. It is a slightly complicated version, it involves power ups for paddle or ball(Multi-Ball, PadLengthIncrement, MagneticPad etc). It also includes a variety of enemies in each level and different positioning of blocks. There are also different types of blocks which take multiple hits to destroy.

This game can be played using Neural Networks,Reinforcement Learning etc. Using Genetic Algorithms for this task is difficult due t o the presence of enemy AI and other constraints.

The game is played using an Emulator called FCEUX. Version 2.2.3. After loading up the game, we can run a Lua script through the emulator to take control of the game.

The whole algorithm is coded in Lua in a single file.

## The Algorithm
In every genetic algorithm we find,

A Population, which contains some members(Chromosome/DNA). These chromosomes contains 'genes' which contain information related to the behaviour of that member.

Each member of the population is given a fitness of how well they perform(survive) in that given task/environment. Based on their fitness, the top members of the population are selected for crossover, where their genes maybe mixed(or some operations performed) for the next generation of the population.
A random mutation may occur in any member of the population to maintain diversity and expand the search space.

Variables related to this game:
The population size is 200. It can be increased to 300 or 400, it will slow down training, but we may converge to the solution faster.
We select the top **cr_rate** percentile of the population for crossover, the remaining are deleted/overwritten.
We have a **mutation_rate** chance of mutating a bit in a member of population.

The fitness is calculated as `100-(NumberOfBlocks/MaxBlocks)*100`.

### The encoding
Each chromosome is encoded as follows,
Each chromosome is a string with binary digits 0,1.
A sequence in a chromosome represents the moves that the paddle will make in 20 Frames(**frame_gap**).
If a '1' is found the paddle is ordered to move left and vice versa.
This may sound like fixed movement in an unpredictable environment. The fact is that the enemy AI movement can actually be predicted and the genetic algorithm can learn to destroy the enemy or avoid it, so I see no problem with that.

A new modification to the chromosome is that, in the beginning its size is 15 (**no_controls**). But such limited amount of controls will allow us to play the game only for 20x15 = 300 Frames only. That is only 5 seconds of the game.Then why use such a limited number of control bits?.
