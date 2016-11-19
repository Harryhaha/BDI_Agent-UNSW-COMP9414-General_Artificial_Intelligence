% 1. trigger(Events, Goals)：
% takes a list of events, each of the form junk(X,Y,S), and computes the corresponding list of goals for the agent, each of the form goal(X,Y,S).

% 2. incorporate_goals(Goals, Beliefs, Intentions, Intentions1)：
% has four arguments: a list of goals each of the form goal(X,Y,S), a list of beliefs (containing one term of the form at(X,Y)), the 
% current list of intentions each of the form [goal(X,Y,S), Plan], and a list to be computed which contains the new goals inserted into the 
% current list of intentions in decreasing order of value, using the distance from the agent to break ties. More precisely, a new goal should 
% be placed immediately before the first goal in the list that has a lower value or which has an equal value and is further away from the agent's 
% current position, without reordering the current list of goals. Note that because of repeated perception of the same event, only new goals 
% should be inserted into the list of intentions. The plan associated with each new goal should be the empty plan (represented as the empty list).

% 3. select_action(Beliefs, Intentions, Intentions1, Action)：
% takes the agent's beliefs (a singleton list containing a term for the agent's location) and the list of intentions, and computes an action to 
% be taken by the agent and the updated list of intentions. The intention selected by the agent is the first on the list of intentions (if any). 
% If the first action in this plan is applicable, the agent selects this action and updates the plan to remove the selected action. If there is 
% no associated plan (i.e. the plan is the empty list) or the first action in the plan for the first intention is not applicable in the current 
% state, the agent constructs a new plan to go from its current position to the goal state and pick up the junk there (this plan will be a list 
% of move actions followed by an pick up action), selects the first action in this new plan, and updates the list of intentions to incorporate 
% the new plan (minus the selected first action). Due to the fact that there are no obstacles in the world, the exact path the agent takes 
% towards the goal does not matter, so choose any convenient way of implementing this procedure.

% 4. update_beliefs(Observation, Beliefs, Beliefs1) and update_intentions(Observation, Intentions, Intentions1)：
% to compute the lists of beliefs and intentions resulting from the agent's observations. These are very simple procedures for updation.





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trigger([],[]).
trigger([junk(X,Y,S)|Events], [goal(X,Y,S)|Goals]) :-
    trigger(Events, Goals).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the base case:
incorporate_goals([], _, Intentions, Intentions) :-!.

% the recursive case, which the goal has already in the Intentions:
incorporate_goals([goal(X,Y,Value)|Goals], Beliefs, Intentions, Intentions1) :-   
    member([goal(X,Y,_), _], Intentions),
    incorporate_goals(Goals, Beliefs, Intentions, Intentions1),!.

% the recursive case, which the goal is a new goal:
incorporate_goals([goal(X,Y,Value)|Goals], Beliefs, Intentions, Intentions1) :-    
    incorporate_a_goal(goal(X,Y,Value), Beliefs, Intentions, TmpIntentions1),    %% incorporate this goal into Intentions and update it. 
    incorporate_goals(Goals, Beliefs, TmpIntentions1, Intentions1),!.            %% continuously incorporate new goal(s).



% the base case:
incorporate_a_goal(goal(X,Y,Value), _, [], [[goal(X,Y,Value),[]]]) :-!.

% the recursive case, which the distance between beliefs and new goal is larger than current specified goal.
incorporate_a_goal(goal(X,Y,Value), [at(X_A,Y_A)], [[goal(X1,Y1,Value1),Plan]|RestOfIntentions], [[goal(X1,Y1,Value1),Plan]|RestOfIntentions1]) :-
    distance((X_A,Y_A),(X1,Y1),D_I),    
    distance((X_A,Y_A),(X,Y),D_G),  
    D_G > D_I,
    incorporate_a_goal(goal(X,Y,Value), [at(X_A,Y_A)], RestOfIntentions, RestOfIntentions1),!.

% the recursive case, which the distance between beliefs and new goal is smaller than current specified goal, then insert the new goal with previous Intentions in order and terminate recursion. 
incorporate_a_goal(goal(X,Y,Value), [at(X_A,Y_A)], [[goal(X1,Y1,Value1),Plan]|RestOfIntentions], [[goal(X,Y,Value),[]]|RestOfIntentions1]) :-
     distance((X_A,Y_A),(X1,Y1),D_I),     
     distance((X_A,Y_A),(X,Y),D_G),
     D_G < D_I,
     RestOfIntentions1 = [[goal(X1,Y1,Value1),Plan]|RestOfIntentions],!.

% the recursive case, which the distance between beliefs and new goal is the same as current specified goal, and new goal's value is smaller than the other. 
incorporate_a_goal(goal(X,Y,Value), [at(X_A,Y_A)], [[goal(X1,Y1,Value1),Plan]|RestOfIntentions], [[goal(X1,Y1,Value1),Plan]|RestOfIntentions1]) :-
     distance((X_A,Y_A),(X1,Y1),D_I),     
     distance((X_A,Y_A),(X,Y),D_G),
     D_G is D_I,
     Value =< Value1,
     incorporate_a_goal(goal(X,Y,Value), [at(X_A,Y_A)], RestOfIntentions, RestOfIntentions1),!.

% the recursive case, which the distance between beliefs and new goal is the same as current specified goal, and new goal's value is larger than the other, then insert the new goal with previous Intentions in order and terminate recursion.
incorporate_a_goal(goal(X,Y,Value), [at(X_A,Y_A)], [[goal(X1,Y1,Value1),Plan]|RestOfIntentions], [[goal(X,Y,Value),[]]|RestOfIntentions1]) :-
     distance((X_A,Y_A),(X1,Y1),D_I),     
     distance((X_A,Y_A),(X,Y),D_G),
     D_G is D_I,
     Value > Value1,
     RestOfIntentions1 = [[goal(X1,Y1,Value1),Plan]|RestOfIntentions],!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the case that there is no any intentions before, then just give a random move.
select_action([at(X_A,Y_A)], [], [], Action) :-
    X_A_Random is X_A + 1,
    Action = move(X_A_Random, Y_A),!.

% the case that there is at least one move action in the plan list within 1st intention and this move action is applicable.
select_action([at(X_A,Y_A)], [[goal(X,Y,Value),[move(X1,Y1)|RestOfPlan]]|RestOfIntentions], Intentions1, Action) :-
    applicable([at(X_A,Y_A)], move(X1,Y1)),
    Action = move(X1,Y1),
    Intentions1 = [[goal(X,Y,Value),RestOfPlan]|RestOfIntentions],!.

% the case that there is a pickup action in the plan list within 1st intention and this pickup action is applicable.
select_action([at(X_A,Y_A)], [[goal(X,Y,Value),[pickup(X1,Y1)|[]]]|RestOfIntentions], Intentions1, Action) :-
    applicable([at(X_A,Y_A)], pickup(X1,Y1)),
    Action = pickup(X1,Y1),
    Intentions1 = [[goal(X,Y,Value),[]]|RestOfIntentions],!.



% the case that there is at least one intention but the 1st plan is empty list, then construct a new plan, updating it.
select_action([at(X_A,Y_A)], [[goal(X,Y,Value),[]]|RestOfIntentions], Intentions1, Action) :-
    construct_new_plan([at(X_A,Y_A)], goal(X,Y,Value), [FirstAction|RestOfNewPlan]),
    Action = FirstAction,
    Intentions1 = [[goal(X,Y,Value), RestOfNewPlan]|RestOfIntentions],!.

% the case that there is at least one intention with plan but the 1st action in this plan list is not applicable(move distance),then construct a new plan, updating it.
select_action([at(X_A,Y_A)], [[goal(X,Y,Value),[move(X1,Y1)|RestOfPlan]]|RestOfIntentions], Intentions1, Action) :-
    not(applicable([at(X_A,Y_A)], move(X1,Y1))),
    construct_new_plan([at(X_A,Y_A)], goal(X,Y,Value), [FirstAction|RestOfNewPlan]),
    Action = FirstAction,
    Intentions1 = [[goal(X,Y,Value), RestOfNewPlan]|RestOfIntentions],!.

% the case that there is at least one intention with plan but the 1st action in this plan list is not applicable(pickup location), then construct a new plan, updating it.
select_action([at(X_A,Y_A)], [[goal(X,Y,Value),[pickup(X1,Y1)|[]]]|RestOfIntentions], Intentions1, Action) :-
    not(applicable([at(X_A,Y_A)], pickup(X1,Y1))),
    construct_new_plan([at(X_A,Y_A)], goal(X,Y,Value), [FirstAction|RestOfNewPlan]),
    Action = FirstAction,
    Intentions1 = [[goal(X,Y,Value), RestOfNewPlan]|RestOfIntentions],!.




% construct the new list(new plan).
construct_new_plan([at(X_A,Y_A)], goal(X,Y,Value), NewPlan) :- 
    Direction_X is X - X_A,
    x_move([at(X_A,Y_A)], goal(X,Y,Value), Direction_X, HoriMove),   %% move horizontally first, closer to the goal.
    Direction_Y is Y - Y_A,
    y_move([at(X,Y_A)], goal(X,Y,Value), Direction_Y, VertMove),     %% then move vertically, closer to the goal.
    append(HoriMove, VertMove, NewPlan).                             
    

% the base case of horizontal movement: when the x of current location is the same as x of the goal.
x_move([at(X,_)], goal(X,_,_), _, []) :-!.

% the recursion case, which the goal is on the right side of the current location.
x_move([at(X_A,Y_A)], goal(X,Y,Value), Direction_X, HoriMove) :-
    Direction_X > 0,
    X_A1 is X_A + 1,
    HoriMove = [move(X_A1,Y_A)|RestOfHoriMove],
    x_move([at(X_A1,Y_A)], goal(X,Y,Value), Direction_X, RestOfHoriMove),!.

% the recursion case, which the goal is on the left side of the current location.
x_move([at(X_A,Y_A)], goal(X,Y,Value), Direction_X, HoriMove) :-
    Direction_X < 0,
    X_A1 is X_A - 1,
    HoriMove = [move(X_A1,Y_A)|RestOfHoriMove],
    x_move([at(X_A1,Y_A)], goal(X,Y,Value), Direction_X, RestOfHoriMove),!.



% the base case of vertical movement: when the y of the current location is the same as y of the goal.
y_move([at(X,Y)], goal(X,Y,_), _, [pickup(X,Y)]) :-!.
    
% the recursive case, which the goal is on the up side of the current location.
y_move([at(X,Y_A)], goal(X,Y,Value), Direction_Y, VertMove) :-
    Direction_Y > 0,
    Y_A1 is Y_A + 1,
    VertMove =  [move(X,Y_A1)|RestOfVertMove],
    y_move([at(X,Y_A1)], goal(X,Y,Value), Direction_Y, RestOfVertMove),!.

% the recursive case, which the goal is on the down side of the current location.
y_move([at(X,Y_A)], goal(X,Y,Value), Direction_Y, VertMove) :-
    Direction_Y < 0,
    Y_A1 is Y_A - 1,
    VertMove =  [move(X,Y_A1)|RestOfVertMove],
    y_move([at(X,Y_A1)], goal(X,Y,Value), Direction_Y, RestOfVertMove).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the case that the Action is move, instead of pickup. In this case, the updated Beliefs1 is the new Beliefs1(location) after this move.
update_beliefs(at(X,Y), Beliefs, [at(X,Y)]) :-!.

% the case that the Action is pickup, instead of move. In this case, the updated Beliefs1 is the same as Beliefs.
update_beliefs(cleaned(X,Y), Beliefs, Beliefs).



% the case that the Action is move, instead of pickup. In this case, the updated Intentions is the same as new Intentions.
update_intentions(at(X,Y), Intentions, Intentions) :-!.

% the case that the Action is pickup, instead of move. In this case, the updated Intentions is the rest of new Intentions.(exclude first intention)
update_intentions(cleaned(X,Y), [FirstIntention | RestOfIntentions], RestOfIntentions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%