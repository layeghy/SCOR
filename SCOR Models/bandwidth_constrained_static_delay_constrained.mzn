/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      SCOR Model for Bandwidth Constrained (static) Delay Constrained Path Routing
*  Objective: Finds the flow paths with constrained maximum (static) delay and bandwidth
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy, Marius Portmann
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  Note: If running in MiniZinc IDE, the model data can be opened, and fed to the model via Project Explorer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

%%%%%%%%% Calling Predicates  %%%%%%%%%%%%
include "../SCOR Predicates/Predicate_flow_path.mzn";
include "../SCOR Predicates/Predicate_path_cost.mzn";
include "../SCOR Predicates/Predicate_defined_capacity.mzn";


%%%%%%%%%%%%%%%%% Declaration  %%%%%%%%%%%%
% Only for using with the supplied model data files
% (These three parameters are declared because they are used in the model data files).
int: c1;
int: c2;
int: c3;

% Cost Constraint (can be delay, num of hops, ...)
int: TC = 10000;

% link parameters
int: d1;
int: d2;
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

% objective function is the path length to be minimized 
array[1..1] of var int: Tcost;

% objective function is to find paths of links with capacity more than limits 
array[1..nFlows] of int: Limits;


%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%
% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint flow_path( membership, Link_info, Nodes, s, t);

% Calculate total distance for each possible path 
constraint path_cost( membership, Link_info, Tcost, Flow_demands);

% remove links with capacity less than Limits
constraint defined_capacity( membership, Flow_demands, Link_info, Limits);

% constraining the total cost to TC
constraint Tcost[1] <= TC;


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
endif | j in 1..nFlows,i in 1.. num_links] ++
        ["\nTotal cost:    [\(fix(Tcost[1]))]"];

