
%%%%%%%%% Calling Predicates  %%%%%%%%%%%%

include "../SCOR Predicates/Predicate_flow_path.mzn";
include "../SCOR Predicates/Predicate_link_utilization.mzn";


%%%%%%%%%%%%%%%%% Declration  %%%%%%%%%%%%
% the limit
float: LUL = 70;         % Link Utilzation Limit in percent

% link parameters
int: d1;
int: d2;
int: c1;
int: c2;
int: c3;
% capacity of links should be more than these values (used in other programs, here just for unifying) 
array[1..nFlows] of int: Limits;


% array of Links
array[int, int] of int: Link_info; 
% number of links 
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


% link membership in path
array[1..num_links,1..nFlows] of var 0..1: membership;
array[1..num_links] of var int: Residual;                   % Residual Capacity of links
array[1..num_links] of var float: Link_utilization;                 % Link Utilization




%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%

% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint flow_path( membership, Link_info, Nodes, s, t);

% Calculate the link utilization for all link
constraint link_utilization( membership, Flow_demands, Link_info, Link_utilization );

% constraint the utilization below limit
constraint max(Link_utilization) <= LUL;




%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
% Solve for Minimum Relative Congestion
solve minimize max(Link_utilization);




%%%%%%%%%%%%%  Output %%%%%%%%%%%%%%%%%%%
output [
if i = 1 then
"\n\n********************* Flow[\(j)] demand = \(Flow_demands[j]) *********************\n" ++
"Path [Link no (n1-n2)]:  " ++
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") LU:"++show_float(-2,2,fix(Link_utilization[i]))++"] ==>" endif 

elseif i = num_links then 
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") LU:"++show_float(-2,2,fix(Link_utilization[i]))++"] " endif ++ "\n"

else
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") LU:"++show_float(-2,2,fix(Link_utilization[i]))++"] ==>" endif 

endif | j in 1..nFlows,i in 1.. num_links] ++  ["\nMaximum Link Utilization: \(max(Link_utilization))%"];



