/*
This model is created on 13-03-2018 to be used in onos

*/
%%%%%%%%% Calling Predicates  %%%%%%%%%%%%

include "Predicate_network_path.mzn";
include "Predicate_path_bottleneck.mzn";
include "Predicate_path_cost.mzn";



%%%%%%%%%%%%%%%%% Declration  %%%%%%%%%%%%
% link parameters
int: d1;
int: d2;
% int: c1;
% int: c2;
% int: c3;
% capacity of links should be more than these values (used in other programs, here just for unifying) 
array[1..nFlows] of int: Limits;

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

% part of objective is to limit the path cost
array[1..1] of var int: Tcost;

% objective function is the BottleNeck to be maximized 
array[1..nFlows] of var int: BottleNeck;



%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%

% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint network_path( membership, Link_info, Nodes, s, t);

% Calculate path bottleneck
constraint path_bottleneck( membership, Link_info, BottleNeck);

% Calculate total distance for each possible path 
constraint path_cost( membership, Link_info, Tcost, Flow_demands);

constraint Tcost[1] <= Limits[1];



%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
solve maximize BottleNeck[1];



%%%%%%%%%%%%%  Output %%%%%%%%%%%%%%%%%%%
output [
if i = 1 then
"\n\n********************* Flow[\(j)] demand = \(Flow_demands[j]) *********************\n" ++
"Path [Link no (n1-n2)]:  " ++
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") " ++ "] ==>" endif 

elseif i = num_links then 
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") " ++ "] " endif ++ "\n"

else
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") " ++ "] ==>" endif 

endif | j in 1..nFlows,i in 1.. num_links] ++ ["\nBottleNeck: \(BottleNeck[1])"];
