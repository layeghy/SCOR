/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      SCOR Model for MaxMin Residual Capacity in wireless networks
*  Objective: Finds the flow paths for multiple concurrent flows in a way that the minimum residual capacity is maximised
% for the half duplex networks such as wireless networks
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy, Marius Portmann
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  Note: If running in MiniZinc IDE, the model data can be opened, and fed to the model via Project Explorer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

%%%%%%%%% Calling Predicates  %%%%%%%%%%%%
include "../SCOR Predicates/Predicate_residual_capacity.mzn";
include "../SCOR Predicates/Predicate_flow_path.mzn";
include "../SCOR Predicates/Predicate_node_capacity.mzn";


%%%%%%%%%%%%%%%%% Declaration  %%%%%%%%%%%%
% Only for using with the supplied model data files
% (These three parameters are declared because they are used in the model data files).
int: c1;
int: c2;
int: c3;

% link parameters
int: d1;
int: d2;
array[int, int] of int: Link_info;
int: num_links = max(index_set_1of2(Link_info));

% nodes
array[int] of int: Nodes;
array[int] of int: Nodes_Capacities;

% Flow Demands
array[int] of int: Flow_demands;
int: nFlows = max(index_set(Flow_demands));

% source node 
array[1..nFlows] of int: s;

% target node 
array[1..nFlows] of int: t;

% edge membership in path
array[1..num_links,1..nFlows] of var 0..1: membership;  

% the residual capacity in each link   
array[1..num_links] of var 0..c1: Residual;                  


%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%
% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint flow_path( membership, Link_info, Nodes, s, t);

% Calculate the residual capacity in each link
constraint residual_capacity( membership, Flow_demands, Link_info, Residual );   

% Limit the the total flow in each link to less than its capacity plus the overbooking
constraint forall(i in 1..num_links)(Residual[i] >=0);

% Apply node capacities for Wireless networks
constraint node_capacity( membership, Flow_demands, Link_info, Nodes_Capacities );  


%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
solve maximize min(Residual);


%%%%%%%%%%%%%  Formatted Output %%%%%%%%%%%%%%%%%%%
output [
if i = 1 then
    "\n\n********************* Flow[\(j)] demand = \(Flow_demands[j]) *********************\n" ++
    "Path [Link no (n1-n2)]:  " ++
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] ==>" endif
elseif i = num_links then
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] " endif ++ "\n"
else
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] ==>" endif
endif | j in 1..nFlows,i in 1.. num_links] ++
        ["\nminimum residual capacity of the path: \(min(Residual))"];

