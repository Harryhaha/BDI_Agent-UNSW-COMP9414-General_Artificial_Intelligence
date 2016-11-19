# BDI_Agent-UNSW-COMP9414-General_Artificial_Intelligence
implement the basic functions of a simple BDI Agent that operates in a Gridworld, using prolog.




# Gridworld
The Gridworld consists of a two-dimensional grid of locations, extending to infinity in both directions. Some locations contain "junk" which the agent must "clean up" in order to score points. An agent cleans up a piece of junk by moving to its location and executing a pickup action. Agents can move one square at a time either horizontally or vertically. The world is dynamic in that junk may spontaneously appear at randomly determined locations at any time, though there is never more than one item of junk in the same location.


“gridworld.pro” implements a system for conducting an experimental trial consisting of one agent in the Gridworld that repeatedly executes the BDI interpretation cycle for 20 iterations (this is a deliberately small number for ease of writing and debugging the program). The initial state of the world is always that there is no junk and the agent is at the location (0,0). 

“agent.pro” is the important methods' implementations

The agent's beliefs at any time simply consist of a list containing one term of the form at(X,Y) representing the current location of the agent. The agent's beliefs are always correct (i.e. if the agent "thinks" it is at location (3,4) then it is at location (3,4)). Hence the initial belief state of the agent is represented by the list [at(0,0)].

The agent's goals at any time are a list of locations of junk and their values. Each goal of the agent is represented as a term goal(X,Y,S), where (X,Y) is the location of a piece of junk and S is its value. The agent's intentions are a list of pairs, each of the form [Goal, Plan], representing a goal with an associated plan (that may be the empty plan), ordered according to some priority.

Each plan is a list of actions. To fulfil an intention, the agent executes the plan associated with the goal, which will make the agent move along a path towards the goal and clean it up. If, when the agent chooses a goal to pursue, the plan associated with the goal is empty or cannot be executed, the agent creates a new plan for the goal and then begins to execute this plan.

In each cycle the agent executes one action; there are two types of action the agent can execute:
   pickup(X,Y) - the agent picks up the junk at (X,Y) and scores the associated points
   move(X,Y)   -   the agent moves to the location (X,Y)




# BDI Interpreter
In each time cycle, the agent executes the interpreter shown abstractly in Figure 2. The new external events on each cycle are represented as a list of terms of the form junk(X,Y,S), indicating the perception of junk at location (X,Y) with value S within some viewing distance of the agent. The agent will repeatedly perceive the same junk item for as long as it is in viewing range. It is not assumed that the agent can see all of the grid, so a new external event may occur as the agent moves (unknowingly) towards a piece of junk. Each new perceived event junk(X,Y,S) triggers a goal for the agent, represented as a term of the form goal(X,Y,S). Any new goal is incorporated into the agent's list of intentions according to the agent's prioritization strategy (see below). The agent then selects one action for execution from the current list of intentions (here the agent always selects the first intention on the list if there is one, creates or modifies the associated plan if necessary, then selects the first action in that plan, removes the selected action from the chosen plan, executes the action, and updates the list of intentions by removing any successfully achieved goals. If there are no current intentions, the agent simply moves to any adjacent location.

Abstract BDI Interpreter:
	initialize-state();
	do
		get-new-external-event(events);
    	G := trigger(events);
    	incorporate-goals(G, I);
    	action := select-action(B, I);
    	execute(action);
    	observe(action, facts);
    	update-beliefs(facts, B);
    	update-intentions(facts, I);
    until quit

The agent's prioritization strategy is very simple: without reordering existing goals, each new goal is inserted into the list of intentions in order of value (higher values before lower values), but if the new goal has the same value as existing goal(s), the new goal is inserted into the list of goals of the same value in order of distance from the current position (closer before further away). This means the agent maintains a "commitment" to pursuing its goals (the agent only changes its intention to pick up a higher value item or a closer item with the same value).




