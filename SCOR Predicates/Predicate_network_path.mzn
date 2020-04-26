% SCOR Predicate

predicate network_path(
                            array[int,int] of var 0..1: Link_Path_Membership,                 % array[1..num_edges,1..nFlows] of var 0..1: x,
                            array[int,int] of int: Link_info,                                     % array[1..num_edges,1..4] of 1..99: Link_info)
                            array[int] of int: Nodes,                                         % aarray[1..n] of 1..n: nodes
                            array[int] of int: Sources,                                       % aarray[1..nFlows] of 1..n: s
                            array[int] of int: Destinations)=                                 % aarray[1..nFlows] of 1..n: t

                        
let {

int: n = max(index_set(Nodes)), 

int: nFlows = max(index_set(Sources)),        % number of source must be same as number of flows

int: num_links = max(index_set_1of2(Link_info)), 

array[1..nFlows] of 1..n: s = Sources,

array[1..nFlows] of 1..n: t = Destinations,

array[int,int] of var 0..1: x = Link_Path_Membership, 

    } 

in 

(
 
assert( 

max(index_set_1of2(x)) == num_links             % memberships must be same as number of links
/\
lb_array(x) == 0                                
/\ 
ub_array(x) == 1
/\
max(index_set(t)) == nFlows,                    % number of destinations must be same as number of flows as sources

"Either source and destination number are not equal, Link_Path_Membership arrays dimension is not correct, or Link_Path_Membership range is not [0,1]",

forall(i in 1..n)(

forall(j in 1..nFlows)(

         sum(k in 1..num_links where Link_info[k,2] = i) (x[k,j]) + (if i = s[j] then 1 else 0 endif)
    = 
         sum(k in 1..num_links where Link_info[k,1] = i) (x[k,j]) + (if i = t[j] then 1 else 0 endif)

/\
   
         sum(k in 1..num_links where Link_info[k,2] = i) (x[k,j]) <= 1

                       )

                 )

       )

);