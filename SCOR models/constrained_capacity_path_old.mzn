
%%%%%%%%% Calling Predicates  %%%%%%%%%%%%

include "Predicate_network_path.mzn";
include "Predicate_path_bottleneck.mzn";



%%%%%%%%%%%%%%%%% Declration  %%%%%%%%%%%%
% Capacity Constraint
int: CC = c1;

% link parameters
int: d1;
int: d2;
int: c1;
int: c2;
int: c3;

% array of edges
array[int, int] of int: Link_info; 
% number of edges 
int: num_links = max(index_set_1of2(Link_info));

% nodes
array[int] of int: Nodes;

% Flow Demands
array[int] of int: Flow_demands;
int: nFlows = max(index_set(Flow_demands));

% source node 
array[1..nFlows] of int: s;

% target node 
array[1..nFlows] of int: t;

% link membership in the path
array[1..num_links,1..nFlows] of var 0..1: membership;  


% objective function is the BottleNeck to be maximized 
array[1..nFlows] of var int: BottleNeck;



%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%

% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint network_path( membership, Link_info, Nodes, s, t);

% Calculate path bottleneck
constraint path_bottleneck( membership, Link_info, BottleNeck);
constraint BottleNeck[1] <= CC;



%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
solve satisfy;



%%%%%%%%%%%%%  Output %%%%%%%%%%%%%%%%%%%
% output
output
["Path:  "] ++ [if fix(membership[i,1]) = 0 then "" else " "++show_int(-7,i) endif | i in 1..num_links]++["\n"]++
["n1-n2: "] ++ [if fix(membership[i,1]) = 0 then "" else show_int(4,Link_info[i,1])++"->"++show_int(1,Link_info[i,2]) endif | i in 1.. num_links]++
["\nBottleNeck: \(BottleNeck[1])"];

