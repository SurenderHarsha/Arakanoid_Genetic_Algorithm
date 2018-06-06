# A Genetic Algorithm to Play Arkanoid

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

I had initially written the project with around a 1000 control bits, completely random. But during crossover, there were two problems, the solution space either became completely random, or fixated at a local minima.
Instead I wanted to it to retain its best features and then explore new features from there. Read below.

### Algorithm
First, the initial population of 200 members play the game individually(Average Laptop) and based on their perfomance their fitness is stored with them

The population table has two columns, one for the input chromosome and the other for its corresponding fitness.
After all 200 members have played, the table is sorted with the highest fit member being first.Then the population is sent to crossover.

**Important**
In crossover, the top performers are selected for crossover, In the first generation they have input control size of 15, since they are the top performers they must have good starting points and methods, therefore to these top members we add a few more random control bits of length **control_gap** (Eg 5). Then for the next generation the size of total control bits for each member is 20. The reason for this is, the best performing part of the chromosome is preserved and new random options are explored from this point onwards.
These first top performers are added to the population. (if Topp=length of top performers then 1 to Topp of population is not filled)
Now the old top performers are taken again and instead of adding new random control bits, we add the starting control bits of other top performers(This ensures that valid moves and behaviour are also passed onto the next generation which might converge to a solution faster). From Topp to len(Population)-10 are filled with these members.
The last 10 members are completely random members with random control bits which are generated then. This has no use in later generations, but in earlier generations this helps keep diversity in different starting positions and has proved to be very very useful while testing.

In Mutation, we iterate throught the members of population and through each bit of a member, with a chance of mutating that bit to its opposite value. The chance of mutation is given by **mutation_rate**. Keep it as low as possible.

Finally we repeat the process above until we find the best fitness to be 100% or the maximum, or until all blocks are destroyed.
Then the winner chromosome will play the game until the script is stopped.

## Observations and Behaviours

The behaviour of the bot mainly depends on the fitness formula it uses. One thing to note is that no information about ball position and block positions and enemy positions are provided to the bot. Only the fitness is provided. The paddle is essentially playing blind, therefore it requires time to master the level.

#### 1.Number of Blocks as a fitness:
 If the fitness used is number of blocks remaining, then the paddle tries to destroy as many blocks as possible, it prioritizes taking the multiball powerup and building tunnels to make the ball bounce inside it. It depends on the starting moves that the bot performs hence the last 10 random population members in crossover. Later on it even learns to bounce back multiple balls at once (in Round 4). The bot plays at a superhuman level and I found this to be the best fitness function.
 
#### 2.Score as a fitness:
  If the fitness used is the total score the player has achieved, it performs moderately, one reason is that Powerups give a lot of score than normal blocks, therefore the paddle prioritizes collecting powerups more than keeping the ball alive in initial stages, this gives it a bad start. The fitness may work, but with a bad start the training may take longer.
  
#### 3.Time as a fitness:
   The time that the player was alive can also be used as a fitness and it performs well in the early stages. But in late game, if there are only one or two blocks left, it prioritizes in wasting time bouncing around rather than hitting the blocks and ending the game.
   
#### 4.Combinational Fitness:
  These fitness can be combined as a combination of score, blocks and time, by giving weightage to their overall contribution to the fitness. But for debugging purposed and observations I used the simpler ones.

#### 5. Time spent away from paddle as fitness:
 One more fitness can be the time spent away from paddle in combination with other fitness, this makes sure that it finds tunnels faster and makes the ball bounce in them more rather than coming back to the paddle again.(Not tested!).
 
#### 6. Growing Chromosome:
 The growth of chromosome size is the main feature that enabled me to complete the algorithm, it allows us to retain best features in a population and also to explore completely new random options maintaining diversity.
 
#### 7.Late generations:
 If the training takes too long then the chromosome size increases a lot while the controls that are actually used are still shorter, in this case, crossover becomes irrelevant and the algorithm depends solely on mutation, hence the reason I am focusing on early convergence. The solution will still be found in late generations, but it is a factor of luck and mutation rate.
Another option can be to put a variable mutation rate as the generations increase, but this may result in the loss of best fit genes. Another solution can be to decrease the **control_gap** after a set of generations( Commented in the code).


Overall, the algorithm performs well.


 1. Round 1 Completion time: approx 8-10 Hours
 2. Round 2 Completion time: approx 4-3 Hours
 3. Round 4 Completion time: approx 2 Hours
 4. Round 3 Found a powerup which lets it skip the level.

The times are time required to learn the level and declare a winner which can complete the level by destroying all blocks.
 
