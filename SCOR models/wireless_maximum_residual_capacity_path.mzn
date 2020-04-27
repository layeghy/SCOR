
%%%%%%%%% Calling Predicates  %%%%%%%%%%%%

include "Predicate_residual_capacity.mzn";
include "Predicate_flow_path.mzn";
include "Predicate_node_capacity.mzn";


%%%%%%%%%%%%%%%%% Declration  %%%%%%%%%%%%
% link parameters
int: d1;
int: d2;
int: c1;
int: c2;
int: c3;

% capacity of links should be more than these values (used in other programs, here just for unifying) 
%array[1..nFlows] of int: Limits;


% array of edges
array[int, int] of int: Link_info; 
% number of edges 
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
constraint network_path( membership, Link_info, Nodes, s, t);

% Calculate the residual capacity in each link
constraint residual_capacity( membership, Flow_demands, Link_info, Residual );   

% Limit the the total flow in each link to less than its capacity plus the overbooking
constraint forall(i in 1..num_links)(Residual[i] >=0);

% Apply node capacities for Wireless networks
constraint node_capacity( membership, Flow_demands, Link_info, Nodes_Capacities );  





%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
% Solve for Maximum - Residual - Capacity
solve maximize min(Residual);




%%%%%%%%%%%%%  Output %%%%%%%%%%%%%%%%%%%
output [
if i = 1 then
"\n\n********************* Flow[\(j)] demand = \(Flow_demands[j]) *********************\n" ++
"Path [Link no (n1-n2)]:  " ++
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] ==>" endif 

elseif i = num_links then 
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] " endif ++ "\n"

else
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] ==>" endif 

endif | j in 1..nFlows,i in 1.. num_links] ++ ["\nminimum residual capacity of the path: \(min(Residual))"];

