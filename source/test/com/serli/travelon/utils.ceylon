import com.serli.travelon { Visitable,
	Visitor,
	Failure,
	failure }

variable Integer nodeCounter = 0;

"""
   Create a new node with given kids. Each created node will have
   a different nodeID.
   """
Node createNode([Node*] kids) {
	Node result = Node(kids, nodeCounter);
	nodeCounter++;
	return result;
}

shared Integer countNewNode() {
	return nodeCounter ++;
}

shared void resetNodeCounter() {
	nodeCounter = 0;
}

"""
   An implementation of the [[Visitable]] interface for
   testing purposes.
   """
class Node(kids=[], nodeId=countNewNode()) satisfies Visitable<Node, Node> {
	
	variable shared [Node*] kids;
	Integer nodeId;
	shared actual variable {Node*} children = kids;
	
	shared Node|Failure accept(Visitor<Node> v) {
		value result = v.visit<Node>(this);
		switch(result)
		case(is Visitable<Node,Node>) {
			return result.node;
		}
		case(is Failure) {
			return failure;
		}
	}
	
	string => "Node-``nodeId``";
	node => this;
}
