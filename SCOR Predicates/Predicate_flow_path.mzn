/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      SCOR Predicate for flow path
*  Objective: Finds paths of flows with known sources and targets
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

predicate flow_path(
          array[int,int] of var 0..1: Link_Path_Membership,              % array[1..num_edges,1..nFlows] of var 0..1: x
          array[int,int] of int: Link_info,                              % array[1..num_edges,1..4] of 1..N: Link_info)
          array[int] of int: Nodes,                                      % aarray[1..n] of 1..n: nodes
          array[int] of int: Sources,                                    % aarray[1..nFlows] of 1..n: s
          array[int] of int: Destinations)=                              % aarray[1..nFlows] of 1..n: t
                        
let {
    int: n = max(index_set(Nodes)),
    int: nFlows = max(index_set(Sources)),                               % number of sources equals number of flows
    int: num_links = max(index_set_1of2(Link_info)),
    array[1..nFlows] of 1..n: s = Sources,
    array[1..nFlows] of 1..n: t = Destinations,
    array[int,int] of var 0..1: x = Link_Path_Membership
}
in
   (
    assert(
            max(index_set_1of2(x)) == num_links                          % memberships equal number of links
            /\
            lb_array(x) == 0
            /\
            ub_array(x) == 1
            /\
            max(index_set(t)) == nFlows,                                 % number of targets equals number of sources
            "Error: explain this assert error message.",
            forall(i in 1..n)(
                   forall(j in 1..nFlows)(
                           sum(k in 1..num_links where Link_info[k,2] = i)(x[k,j]) +
                           (if i = s[j] then 1 else 0 endif)
                           =
                           sum(k in 1..num_links where Link_info[k,1] = i)(x[k,j]) +
                           (if i = t[j] then 1 else 0 endif)
                           /\
                           sum(k in 1..num_links where Link_info[k,2] = i) (x[k,j]) <= 1
                   )
            )
    )
);