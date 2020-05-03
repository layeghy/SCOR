/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      AppComponent
*  Objective: This is the second file of three files conforming the SCOR Specific Controller Module (SCCM) for ONOS
*  and "Bandwidth-Constrained Least-(static) Delay Path" routing algorithms
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy, Marius Portmann
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  Note: If running in MiniZinc IDE, the model data can be opened, and fed to the model via Project Explorer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/


package pSCOR.app;

import org.onlab.packet.*;
import org.onosproject.core.ApplicationId;
import org.onosproject.net.*;
import org.onosproject.net.flow.*;
import org.onosproject.net.host.HostService;
import org.onosproject.net.packet.InboundPacket;
import org.onosproject.net.packet.PacketContext;
import org.onosproject.net.topology.DefaultTopologyEdge;
import org.onosproject.net.topology.TopologyEdge;
import org.onosproject.net.topology.TopologyGraph;
import org.onosproject.net.topology.TopologyVertex;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;


public class FrameWork {

    private final Logger logIt = LoggerFactory.getLogger(getClass());
    protected ApplicationId theAppId;
    protected FlowRuleService theFlowRuleService;
    protected TopologyGraph theGraph;
    protected HostService theHostService;

    //Constructor
    FrameWork(ApplicationId myAppId,FlowRuleService myRuleService, TopologyGraph myGraph, HostService myHostService ){
        this.theAppId = myAppId;
        this.theFlowRuleService = myRuleService;
        this.theGraph = myGraph;
        this.theHostService = myHostService;
    }

    // Probably I need to delete as will not be used anymore
    protected static Map<DeviceId, Map<MacAddress, PortNumber>> myTable =
            new HashMap<DeviceId, Map<MacAddress, PortNumber>>();

    /*  ****************** graphTranslator: Method to ceate Adjacncy List as needed by MiniZinc ***********************/
    protected List graphTranslator(List<DeviceId> srcIds, List<DeviceId> dstIds) {

        List Nodes = new ArrayList();
        for (TopologyVertex v : theGraph.getVertexes()) {
            TopologyVertex AdjNode = v;
            Nodes.add(AdjNode.deviceId());
        }

        List adjacencyList = new ArrayList();
        for (TopologyEdge E : theGraph.getEdges()){
            List temp = new ArrayList();
            temp.add(Nodes.indexOf(E.link().src().deviceId())+1);
            temp.add(Nodes.indexOf(E.link().dst().deviceId())+1);
            adjacencyList.add(temp);
        }

        List srcList = new ArrayList();
        List dstList = new ArrayList();

        for (int i=0;i<srcIds.size();i++) {
            srcList.add(Nodes.indexOf(srcIds.get(i)) + 1);
            dstList.add(Nodes.indexOf(dstIds.get(i)) + 1);
        }

        List mznTranslated = new ArrayList();
        mznTranslated.add(adjacencyList);
        mznTranslated.add(srcList);
        mznTranslated.add(dstList);

        return mznTranslated;
    }


    /* ****************************** callMiniZinc ********************************* */
    protected Map callMiniZinc(List adList, int[] lCapacities, int[] lCosts, String rMethod,
                               String Solver, String cDir, int[] fLimits, int[] fDemands){

        int n_nodes = theGraph.getVertexes().size();
        List <Integer> nodes_list = new ArrayList<Integer>();
        /* For the MiniZinc, we need node numbers start from 1 NOT 0 */
        for(int i =1;i<n_nodes+1;i++) nodes_list.add(i);
        int n_links = theGraph.getEdges().size();
        int n_flows = fDemands.length;

        String cost1 = "d1 = " + lCosts[0] + ";";
        String cost2 = "d2 = " + lCosts[0] + ";";
        String capacity1 = "c1 = " + lCapacities[0] + ";";
        String capacity2 = "c2 = " + lCapacities[0] + ";";
        String capacity3 = "c3 = " + lCapacities[0] + ";";
        String nodesArray = "Nodes = array1d(1.." + n_nodes + "," + nodes_list + ");";

        ArrayList allLinks = (ArrayList) adList.get(0);
        ArrayList allSources = (ArrayList) adList.get(1);
        ArrayList allTargets = (ArrayList) adList.get(2);

        String linkList= "";
        ArrayList eachLink;
        for (int i=0;i<n_links;i++) {
            for (int j=0;j<2;j++){
                eachLink = (ArrayList) allLinks.get(i);
                if (i==n_links-1 && j==1){
                    linkList += eachLink.get(j).toString() + "," + lCosts[0] + "," + lCapacities[0];
                }
                else if(j==1) linkList += eachLink.get(j).toString() + "," + lCosts[0] + "," + lCapacities[0] + ",";
                else linkList += eachLink.get(j).toString() + ",";
            }

        }
        String linksArray = "Link_info = array2d(1.." + n_links + ", 1..4,[" + linkList + "]);";
        String flows = "Flow_demands =  [";
        String sources = "s = [" ;
        String targets = "t = [";
        String limits = "Limits = [";
        for(int i=0;i<fDemands.length;i++) {
            if (i < fDemands.length - 1) {
                flows += fDemands[i] + ",";
                sources += allSources.get(i).toString() + ",";
                targets += allTargets.get(i).toString() + ",";
                limits += fLimits[i] + ",";
            }
            else {
                flows += String.valueOf(fDemands[i]) + "];";
                sources += allSources.get(i).toString() + "];";
                targets += allTargets.get(i).toString() + "];";
                limits += String.valueOf(fLimits[i]) + "];";
            }
        }

        String dataString = cost1 + cost2 + capacity1 + capacity2 + capacity3 +
                            nodesArray + linksArray + flows + sources + targets +
                            limits;

        /* this is path to minizinc code + its name */
        String  minizincCode = cDir + rMethod + ".mzn";

        /* this is the call to miniZinc */
        String minizincOutput="";
        try {
            ProcessBuilder builder = new ProcessBuilder(Solver,minizincCode, "-D", dataString, "-s");
            Process process = builder.start();
            InputStream stdout = process.getInputStream ();
            BufferedReader in = new BufferedReader (new InputStreamReader(stdout));
            minizincOutput = in.readLine();
            /* todo: We need do something when mzn cannot find a path */
            if (minizincOutput == "=====UNSATISFIABLE====="){
                logIt.info("Minizinc says: "+minizincOutput);
            } else if (minizincOutput==null){
                logIt.info("Minizinc output: "+minizincOutput);
            }
            in.close();
        }
        catch (IOException e){
            logIt.info(e.toString());
            logIt.info("Minizinc says: "+minizincOutput);
        }

        /* removing the [ and ] */
        minizincOutput = minizincOutput.substring(1, minizincOutput.length() - 1);
        /* removing white spaces */
        minizincOutput = minizincOutput.replaceAll("\\s+", "");
        /* removing the commas */
        String[] outputStrList = minizincOutput.split(",");
        /* Convert it to a list of numbers */
        List<Integer> outputIntList = new ArrayList<Integer>();
        for (String s : outputStrList) {
            outputIntList.add(Integer.valueOf(s));
        }

        List allFlowsForwardSources = new ArrayList<>();
        List allFlowBackwardSources = new ArrayList<>();

        // This is because MiniZinc returns paths for all flows in the same vector
        for (int j=0;j<n_flows;j++){
            List<ConnectPoint> forwardSources = new ArrayList<>();
            List<ConnectPoint> backwardSources = new ArrayList<>();
            // link number (in the graph)
            int l = 0;
            for (int i=0+j; i< outputIntList.size();i+=n_flows ){
                if (outputIntList.get(i)!= 0){
                    /* creating a list of sources of forward and back ward links for each flow*/
                    forwardSources.add(((DefaultTopologyEdge)theGraph.getEdges().toArray()[l]).link().src());
                    backwardSources.add(((DefaultTopologyEdge)theGraph.getEdges().toArray()[l]).link().dst());
                }
                l ++;
            }
            allFlowsForwardSources.add(forwardSources);
            allFlowBackwardSources.add(backwardSources);
        }

        /* This the dictionary which includes src and destination of routes */
        HashMap rRules = new HashMap();
        rRules.put("forward",allFlowsForwardSources);
        rRules.put("backward",allFlowBackwardSources);

        return rRules;
    }


    /* ****************************** flowsInstaller ********************************* */
    public void flowsInstaller(short ethType, List switchPortList, List theFlow){

        setupConfig config = new setupConfig();
        int priority = config.priority;
        Byte ip_proto = (Byte) theFlow.get(4);

        for(int i=0;i<switchPortList.size();i++) {
            DeviceId swId = (DeviceId) ((ConnectPoint)switchPortList.toArray()[i]).elementId();
            PortNumber outPort = ((ConnectPoint)switchPortList.toArray()[i]).port();
            IpAddress srcIP4 = (IpAddress) theFlow.get(0);
            IpAddress dstIP4 = (IpAddress) theFlow.get(2);

            /* In a real network we route based on IP prefix not IP, we need here as well */
            Ip4Prefix matchIp4SrcPrefix =
                    Ip4Prefix.valueOf(srcIP4.getIp4Address(),
                            Ip4Prefix.MAX_MASK_LENGTH);
            Ip4Prefix matchIp4DstPrefix =
                    Ip4Prefix.valueOf(dstIP4.getIp4Address(),
                            Ip4Prefix.MAX_MASK_LENGTH);

            /* Then we install forwarding rules to avoid Pkt-in next time */
            TrafficSelector.Builder trafficSelector = DefaultTrafficSelector.builder();

            if(theFlow.get(1).equals(0)) {
                int dstTCP = (int) theFlow.get(3);
                /* The Match criteria */
                trafficSelector
                        .matchIPSrc(matchIp4SrcPrefix)
                        .matchEthType(ethType)
                        .matchIPProtocol(ip_proto)
                        .matchTcpDst(TpPort.tpPort(dstTCP))
                        .matchIPDst(matchIp4DstPrefix);
            } else {
                int srcTCP = (int) theFlow.get(1);
                /* The Match criteria */
                trafficSelector
                        .matchIPSrc(matchIp4SrcPrefix)
                        .matchEthType(ethType)
                        .matchIPProtocol(ip_proto)
                        .matchTcpSrc(TpPort.tpPort(srcTCP))
                        .matchIPDst(matchIp4DstPrefix);
            }

            /* The Action */
            TrafficTreatment treatment = DefaultTrafficTreatment.builder()
                    .setOutput(outPort)
                    .immediate()
                    .build();

            /* The rule */
            FlowRule flowRule = DefaultFlowRule.builder()
                    .forDevice(swId)
                    .withSelector(trafficSelector.build())
                    .withTreatment(treatment)
                    .withPriority(priority)
                    .fromApp(theAppId)
                    .makePermanent()
                    .build();

            /* Install the rule */
            theFlowRuleService.applyFlowRules(flowRule);
        }
    return;
    }
}







