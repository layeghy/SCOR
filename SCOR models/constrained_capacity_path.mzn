%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File:      SCOR Model for Constrained Capacity path
% Objective: Finds the flow paths for multiple concurrent flows, each path has a minimum specified capacity
% Github:    https://github.com/layeghy/SCOR
% Author:    Siamak Layeghy, Marius Portmann
% Email:     Siamak.Layeghy@uq.net.au
% Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: If running in MiniZinc IDE, the model data can be opened, and fed to the model via Project Explorer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Calling Predicates  %%%%%%%%%%%%
include "../SCOR Predicates/Predicate_flow_path.mzn";
include "../SCOR Predicates/Predicate_capacity_limit.mzn";

%%%%%%%%%%%%%%%%% Declaration  %%%%%%%%%%%%
% Capacity Constraint
int: CC = c1;

% link parameters
int: d1;
int: d2;
int: c1;
int: c2;
int: c3;
array[int, int] of int: Link_info;
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

% objective function is to find paths of links with capacity more than limits 
array[1..nFlows] of int: Limits;


%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%
% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint flow_path( membership, Link_info, Nodes, s, t);

% remove links with capacity less than Limits
constraint capacity_limit( membership, Flow_demands, Link_info, Limits);


%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
solve satisfy;


%%%%%%%%%%%%%  Formatted Output %%%%%%%%%%%%%%%%%%%
output [
if i = 1 then
    "\n\n********************* Flow[\(j)] demand = \(Flow_demands[j]) *********************\n" ++
    "Path [Link no (n1-n2)]:  " ++
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") "++"] ==>" endif
elseif i = num_links then
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") "++"] " endif ++ "\n"
else
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") "++"] ==>" endif
endif | j in 1..nFlows,i in 1.. num_links];

