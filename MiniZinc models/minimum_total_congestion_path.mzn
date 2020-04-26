
%%%%%%%%% Calling Predicates  %%%%%%%%%%%%

include "Predicate_network_path.mzn";
include "Predicate_link_congestion_v2.mzn";



%%%%%%%%%%%%%%%%% Declration  %%%%%%%%%%%%
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


% edge membership in path
array[1..num_links,1..nFlows] of var 0..1: membership;
array[1..num_links] of var float: Congestion;                 % Link congestion




%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%

% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint network_path( membership, Link_info, Nodes, s, t);

% Calculate the link congestion for all link
constraint congestion( membership, Flow_demands, Link_info, Congestion );




%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
% Solve for Minimum total Congestion path
solve minimize sum(Congestion);



%%%%%%%%%%%%%  Output %%%%%%%%%%%%%%%%%%%
output [
if i = 1 then
"\n\n********************* Flow[\(j)] demand = \(Flow_demands[j]) *********************\n" ++
"Path [Link no (n1-n2)]:  " ++
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") Congestion:"++show_float(-2,2,fix(congestion[i]))++"] ==>" endif 

elseif i = num_links then 
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") Congestion:"++show_float(-2,2,fix(congestion[i]))++"] " endif ++ "\n"

else
if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++ 
if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++"->"++show_int(-2,Link_info[i,2])++") Congestion:"++show_float(-2,2,fix(congestion[i]))++"] ==>" endif 

endif | j in 1..nFlows,i in 1.. num_links] ++  ["\ntotal paths congestion: \(sum(Congestion))"];

