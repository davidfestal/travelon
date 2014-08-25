import com.serli.travelon {
    Visitable,
    Visitor,
    Failure,
    failure
}

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
    return nodeCounter++;
}

shared void resetNodeCounter() {
    nodeCounter = 0;
}

"""
   An implementation of the [[Visitable]] interface for
   testing purposes.
   """
class Node(kids = [], nodeId = countNewNode()) satisfies Visitable<Node,Node> {
    
    shared variable [Node*] kids;
    variable {Node*}? _children = null;
    Integer nodeId;
    
    shared actual {Node*} childrenToVisit {
        {Node*} result;
        if (exists c = _children) {
            result = c;
        } else {
            result = kids;
            _children = result;
        }
        return result;
    }
    shared actual Visitable<Node,Node> updateChildrenToVisit({Node*} newChildren) {
        _children = newChildren;
        return this;
    }
    resetChildren() => _children = kids;
    
    shared Node|Failure accept(Visitor<Node> v) {
        value result = v.visit<Node>(this);
        switch (result)
        case (is Visitable<Node,Node>) {
            return result.node;
        }
        case (is Failure) {
            return failure;
        }
    }
    
    string => "Node-``nodeId``";
    node => this;
}
