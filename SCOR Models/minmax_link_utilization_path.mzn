/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      SCOR Model for MinMax Link Utilization
*  Objective: Finds the flow paths while minimizing the maximum link utilization
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  Note: If running in MiniZinc IDE, the model data can be opened, and fed to the model via Project Explorer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

%%%%%%%%% Calling Predicates  %%%%%%%%%%%%
include "../SCOR Predicates/Predicate_flow_path.mzn";
include "../SCOR Predicates/Predicate_link_utilization.mzn";


%%%%%%%%%%%%%%%%% Declration  %%%%%%%%%%%%
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

% Flow Demands
array[int] of int: Flow_demands;
int: nFlows = max(index_set(Flow_demands));

% source nodes 
array[1..nFlows] of int: s;

% target nodes 
array[1..nFlows] of int: t;

% edge membership in path
array[1..num_links,1..nFlows] of var 0..1: membership;
array[1..num_links] of var int: Residual;
array[1..num_links] of var float: Link_utilization;


%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%
% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint flow_path( membership, Link_info, Nodes, s, t);

% Calculate the link utilization for all link
constraint link_utilization( membership, Flow_demands, Link_info, Link_utilization );

% constraint the utilization below 100% less than link capacitys
constraint max(Link_utilization) <= 100;


%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
% Solve to minimize the maximum link utilization
solve minimize max(Link_utilization);


%%%%%%%%%%%%%  Formatted Output %%%%%%%%%%%%%%%%%%%
output [
if i = 1 then
    "\n\n********************* Flow[\(j)] demand = \(Flow_demands[j]) *********************\n" ++
    "Path [Link no (n1-n2)]:  " ++
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") LU:"++show_float(-2,2,fix(Link_utilization[i]))++"] ==>" endif
elseif i = num_links then 
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") LU:"++show_float(-2,2,fix(Link_utilization[i]))++"] " endif ++ "\n"
else
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") LU:"++show_float(-2,2,fix(Link_utilization[i]))++"] ==>" endif
endif | j in 1..nFlows,i in 1.. num_links] ++
        ["\nMaximum Link Utilization: \(max(Link_utilization))%"];



